;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 16 of 24
;; This is STEP 16 of 25 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-15 must have run first, including the init steps between deploys.
;; 1 source file(s), 151,366 gas measured in the REPL gas model, 244,414 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_02/2_Core/03_AQP/03_AQP.pact
;;
;; TOTAL: 1 interface(s), 1 module(s), 13 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/03_AQP.pact
;;      interface  AcquisitionPoolsV1
;;      module     AQP-POOL
;;      table      P|T
;;      table      P|MT
;;      table      AQP|T|Pool
;;      table      AQP|T|DPTFTracker
;;      table      AQP|T|DPOFTracker
;;      table      AQP|T|DPSFTracker
;;      table      AQP|T|DPNFTracker
;;      table      AQP|T|BenDptfTotal
;;      table      AQP|T|BenDpsfNonceTotal
;;      table      AQP|T|BenDpnfNonceTotal
;;      table      AQP|T|BenDpsfAnkMeta
;;      table      AQP|T|BenDpnfAnkMeta
;;      table      AQP|T|UserOccupancy
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/03_AQP.pact ==============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface AcquisitionPoolsV1
    @doc "Interface for AQP acquisition pools and staking. Declares tracker key builders and \
        \ readers for pool config, per-(pool,asset,owner,beneficiary) stake trackers \
        \ (DPTF/DPOF/DPSF/DPNF), and per-beneficiary rollups/anchor-sync state; URC_ \
        \ stake/unstake admission checks; URH_ heavy stake enumerations; XE_/XB_ transfer, \
        \ pool-tracker, rollup, vacate-state and sync building blocks; and \
        \ C_Issue/C_AddScore/C_*PoolStake/C_Sync client entrypoints."

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    (defun GOV|Demiurgoi ())

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables  ⟨cannot exist in an interface⟩
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;{3.2}  schemas
    ;;{3.3}  tables  ⟨cannot exist in an interface⟩

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;{5.2}  Compute [UC]
    ;; [UC]  compute
    ;;
    (defun UCk_DPTFTracker:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UCk_DPOFTracker:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UCk_DPSFTracker:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UCk_DPNFTracker:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UCk_BenDptfTotal:string (beneficiary-id:string dptf-id:string))
    (defun UCk_BenDpsfNonceTotal:string (beneficiary-id:string dpsf-id:string nonce:integer))
    (defun UCk_BenDpnfNonceTotal:string (beneficiary-id:string dpnf-id:string nonce:integer))
    (defun UCk_BenDpsfAnkMeta:string (beneficiary-id:string dpsf-id:string))
    (defun UCk_BenDpnfAnkMeta:string (beneficiary-id:string dpnf-id:string))
    (defun UCk_UserOccupancy:string (pool-id:string beneficiary-id:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [UR]  read
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
    (defun UR_AQP|PoolNns:integer (pool-id:string))
    (defun UR_AQP|UserUnn:integer (pool-id:string beneficiary-id:string))
    (defun UR_AQP|PoolSweepInProgress:bool (pool-id:string))
    (defun UR_AQP|PoolVacateSession:object (pool-id:string))
    ;;
    (defun UR_AQP|DPTFTrackerBalance:decimal (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UR_AQP|DPTFTrackerPoolId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UR_AQP|DPTFTrackerDptfId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UR_AQP|DPTFTrackerOwnerId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    (defun UR_AQP|DPTFTrackerBeneficiaryId:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string))
    ;;
    (defun UR_AQP|BenDptfTotalBalance:decimal (beneficiary-id:string dptf-id:string))
    (defun UR_AQP|BenDptfLastAnkSyncCount:integer (beneficiary-id:string dptf-id:string))
    (defun URC_BenDptfAnchorsNeedSync:bool (beneficiary-id:string dptf-id:string))
    ;;
    (defun UR_AQP|BenDpsfNonceAmount:integer (beneficiary-id:string dpsf-id:string nonce:integer))
    (defun UR_AQP|BenDpsfLastAnkSyncCount:integer (beneficiary-id:string dpsf-id:string))
    (defun UR_AQP|BenDpsfActiveNonceCount:integer (beneficiary-id:string dpsf-id:string))
    (defun URC_BenDpsfHasStake:bool (beneficiary-id:string dpsf-id:string))
    (defun URC_BenDpsfAnchorsNeedSync:bool (beneficiary-id:string dpsf-id:string))
    ;;
    (defun UR_AQP|BenDpnfNonceAmount:integer (beneficiary-id:string dpnf-id:string nonce:integer))
    (defun UR_AQP|BenDpnfLastAnkSyncCount:integer (beneficiary-id:string dpnf-id:string))
    (defun UR_AQP|BenDpnfActiveNonceCount:integer (beneficiary-id:string dpnf-id:string))
    (defun URC_BenDpnfHasStake:bool (beneficiary-id:string dpnf-id:string))
    (defun URC_BenDpnfAnchorsNeedSync:bool (beneficiary-id:string dpnf-id:string))
    ;;
    (defun UR_AQP|DPOFTrackerBalance:decimal (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPOFTrackerPoolId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPOFTrackerDpofId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPOFTrackerOwnerId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPOFTrackerBeneficiaryId:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPOFTrackerNonce:integer (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer))
    ;;
    (defun UR_AQP|DPSFTrackerBalance:decimal (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPSFTrackerPoolId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPSFTrackerDpsfId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPSFTrackerOwnerId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPSFTrackerBeneficiaryId:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPSFTrackerNonce:integer (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer))
    ;;
    (defun UR_AQP|DPNFTrackerBalance:decimal (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPNFTrackerPoolId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPNFTrackerDpnfId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPNFTrackerOwnerId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPNFTrackerBeneficiaryId:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    (defun UR_AQP|DPNFTrackerNonce:integer (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer))
    ;;  Remaining C_* here: C_VacatePool (see README_AQP.md).
    ;;
    (defun URC_DptfStakeIsNativeLeg:bool (dptf-id:string))
    (defun URC_PoolActiveScoreIds:[string] (pool-id:string))
    (defun URC_PoolHasEmployedScores:bool (pool-id:string))
    (defun URC_PoolStakeAdmissionOk:bool (pool-id:string))
    (defun URC_PoolUnstakeAdmissionOk:bool (pool-id:string))
    (defun URC_StakeTrueFungiblePoolClassOk:bool (pool-id:string))
    (defun URC_StakeTrueFungibleDptfMatchesPool:bool (pool-id:string dptf-id:string))
    (defun URC_StakeOrtoFungiblePoolClassOk:bool (pool-id:string))
    (defun URC_StakeOrtoFungibleDpofMatchesPool:bool (pool-id:string dpof-id:string))
    (defun URC_OrtoUnstakeNoncesSufficient:bool
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[decimal])
    )
    (defun URC_StakeCollectablePoolClassOk:bool (pool-id:string son:bool))
    (defun URC_StakeCollectableMatchesPool:bool (pool-id:string collectable-id:string))
    ;; Dead-definition guard for the score-definition write path (2026-10-06). Declared here
    ;; so Talos can call it by modref before delegating to AQP-SCORE.
    (defun UEV_ScoreDefinitionTargetMatchesPool (score-id:string asset-id:string))
    (defun URC_CollectableUnstakeNoncesSufficient:bool
        (pool-id:string collectable-id:string son:bool owner-id:string beneficiary-id:string nonces:[integer] nonce-amounts:[integer])
    )
    ;; [URH] heavy-read
    ;;
    (defun URH_AQP|AllPoolIds:[string] ())
    (defun URH_AQP|ActiveDptfTrackerRows:[object] (pool-id:string dptf-id:string))
    (defun URH_AQP|ActiveDpofTrackerRows:[object] (pool-id:string dpof-id:string))
    (defun URH_AQP|ActiveDpsfTrackerRows:[object] (pool-id:string dpsf-id:string))
    (defun URH_AQP|ActiveDpnfTrackerRows:[object] (pool-id:string dpnf-id:string))
    ;; M5 (#14) UI observability — cross-pool per-user stake legs (owner-side + beneficiary-side).
    (defun URH_AQP|DptfStakesByOwner:[object] (owner-id:string))
    (defun URH_AQP|DptfStakesByBeneficiary:[object] (beneficiary-id:string))
    (defun URH_AQP|DpofStakesByOwner:[object] (owner-id:string))
    (defun URH_AQP|DpofStakesByBeneficiary:[object] (beneficiary-id:string))
    (defun URH_AQP|DpsfStakesByOwner:[object] (owner-id:string))
    (defun URH_AQP|DpsfStakesByBeneficiary:[object] (beneficiary-id:string))
    (defun URH_AQP|DpnfStakesByOwner:[object] (owner-id:string))
    (defun URH_AQP|DpnfStakesByBeneficiary:[object] (beneficiary-id:string))
    (defun URH_AQP|BenDpsfActiveNonceSupplies:[object] (beneficiary-id:string dpsf-id:string))
    (defun URH_AQP|BenDpnfActiveNonceSupplies:[object] (beneficiary-id:string dpnf-id:string))
    ;;
    ;; [URCi]   cost readers — single source for exec billing + INFO preview (config/sync ops)
    (defun URCi_Issue:object{IgnisCollectorV3.OutputCumulator} (output:[string]))
    (defun URCi_IssueStoa:decimal ())
    (defun URCi_AddScore:object{IgnisCollectorV3.OutputCumulator} (output:[string]))
    (defun URCi_RevokeScore:object{IgnisCollectorV3.OutputCumulator} (output:[string]))
    (defun URCi_SetPoolStake:object{IgnisCollectorV3.OutputCumulator} (output:[string]))
    (defun URCi_SyncTrueFungibleAnchors:object{IgnisCollectorV3.OutputCumulator} (output:[string]))
    (defun URCi_SyncCollectableAnchors:object{IgnisCollectorV3.OutputCumulator} (output:[string]))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;; [XE]
    ;;
    (defun XE_ZeroDptfTrackerSlot:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string)
    )
    (defun XE_SetVacateJobState:string
        (pool-id:string vacate-in-progress:bool)
    )
    (defun XE_SetSweepInProgress:string
        (pool-id:string flag:bool)
    )
    (defun XE_TrueFungibleTransfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    )
    (defun XE_TrueFungiblePoolTracker:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    )
    (defun XE_TrueFungibleBeneficiaryRollup:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    )
    (defun XE_OrtoFungibleTransfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
    )
    (defun XE_OrtoFungiblePoolTracker:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
    )
    (defun XE_CollectableTransfer:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string
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
    (defun XE_CollectablePoolTracker:object{IgnisCollectorV3.OutputCumulator}
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
    (defun XE_CollectableBeneficiaryRollup:object{IgnisCollectorV3.OutputCumulator}
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
    ;; [XB]
    (defun XB_SetPoolStakeEnabled:string (pool-id:string enabled:bool))
    (defun XB_SetBenDptfAnkSyncCount:object{IgnisCollectorV3.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
    )
    (defun XB_SetBenCollectableAnkSyncCount:object{IgnisCollectorV3.OutputCumulator}
        (beneficiary-id:string collectable-id:string son:bool)
    )
    ;;{5.7}  User [A/C]
    ;; [C]   client
    ;;
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-name:string asset-id:string aqp-class:integer)
    )
    (defun C_AddScore:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string score-id:string)
    )
    (defun C_RevokeScore:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string score-id:string)
    )
    (defun C_DisablePoolStake:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string)
    )
    (defun C_EnablePoolStake:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string)
    )
    ;;
    (defun C_SyncTrueFungibleAnchors:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executee:string dptf-id:string)
    )
    (defun C_SyncCollectableAnchors:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executee:string collectable-id:string son:bool)
    )

)
(module AQP-POOL GOV
    @doc "Sovereign acquisition-pool module. Owns pool definitions (asset, aqp-class, up to \
        \ 7 employed scores, stake-enabled/vacate/sweep state, occupancy counts), \
        \ per-position stake trackers for TF/OF/SF/NF assets, and per-beneficiary balance \
        \ rollups with anchor-sync counters. Handles pool issuance, add/revoke score, \
        \ enable/disable staking, custody transfers and anchor sync; stake/unstake token \
        \ movement and tracker/rollup writes flow through its XE_/XB_ blocks driven by \
        \ Talos/FVT."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements AcquisitionPoolsV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;(implements DemiourgosPactDigitalCollectibles-UtilityPrototype)
    ;;
    (defconst GOV|MD_AQP                                (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|AQP_ADMIN)))
    (defcap GOV|AQP_ADMIN ()                            (enforce-guard GOV|MD_AQP))
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
        (with-capability (GOV|AQP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|AQP_ADMIN)
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
        (with-capability (GOV|AQP_ADMIN)
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
        (with-capability (GOV|AQP_ADMIN)
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
        @doc "Post-deploy IMC wiring (AQP-BOOT Step 0). TFT + DPOF vault transfer/receive on AQP|SC_NAME."
        (let
            (
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                ;;
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|AQP|CALLER)))
            )
            ;; AQP-POOL → TFT: XE_TrueFungibleTransfer calls TFT::C_Transfer; TFT P|UEV_IMC requires this guard.
            (ref-P|TFT::P|A_AddIMP mg)
            ;; AQP-POOL → DPOF: XE_OrtoFungibleTransfer calls DPOF::C_Transfer; vacate batch is AQP-VCT → DPOF::C_BulkTransfer.
            (ref-P|DPOF::P|A_AddIMP mg)
            ;; AQP-POOL → DPDC-T: XE_CollectableTransfer calls DPDC-T::C_Transfer; vacate batch is AQP-VCT → DPDC-T::C_BulkTransfer.
            (ref-P|DPDC-T::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
            true
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst GAS|ISSUE-POOL                        (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "issue-pool")))
    (defconst GAS|ADD-SCORE                         (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "add-score")))
    (defconst GAS|REVOKE-SCORE                      (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "revoke-score")))
    (defconst GAS|SET-POOL-STAKE                    (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "pool-stake-toggle")))
    (defconst GAS|SYNC-TF-ANCHORS                   (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "sync-anchors")))
    (defconst GAS|SYNC-COLLECTABLE-ANCHORS          (let ((ref-IGNIS:module{IgnisCollectorV3} IGNIS)) (ref-IGNIS::UC_IgnisDeter "sync-anchors")))
    (defconst EOC                                       (CT_EmptyCumulator))
    (defconst AQP|SC_NAME                               (CT_AqpScName))
    ;;{3.2}  schemas
    ;;
    ;; [1] AQP|T|Pool
    ;;
    ;; [2] AQP|T|DPTFTracker
    ;;
    ;; [3] AQP|T|DPOFTracker
    ;;
    ;; [4] AQP|T|DPSFTracker
    ;;
    ;; [5] AQP|T|DPNFTracker
    ;;
    ;; [8] AQP|T|BenDptfTotal
    ;;Ben × asset rollups (pool-agnostic totals for ANK sync — see README_AQP.md § Anchor sync)
    ;;
    ;; [9] AQP|T|BenDpsfNonceTotal
    ;;
    ;; [10] AQP|T|BenDpnfNonceTotal
    ;;
    ;; [11] AQP|T|BenDpsfAnkMeta
    ;;
    ;; [12] AQP|T|BenDpnfAnkMeta
    ;;
    ;; [13] AQP|T|UserOccupancy
    ;;{3.3}  tables
    ;;
    (deftable AQP|T|Pool:{AcquisitionSchemasV1.AQP|Schema})                                  ;;1] Key = <Pool-ID>
    (deftable AQP|T|DPTFTracker:{AcquisitionSchemasV1.AQP|TrueFungibleTracker})              ;;2] Key = <Pool-ID> | <DPTF-ID> | <Owner-ID> | <Beneficiary-ID>
    (deftable AQP|T|DPOFTracker:{AcquisitionSchemasV1.AQP|OrtoFungibleTracker})              ;;3] Key = <Pool-ID> | <DPOF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce>
    (deftable AQP|T|DPSFTracker:{AcquisitionSchemasV1.AQP|SemiFungibleTracker})              ;;4] Key = <Pool-ID> | <DPSF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce>
    (deftable AQP|T|DPNFTracker:{AcquisitionSchemasV1.AQP|NonFungibleTracker})               ;;5] Key = <Pool-ID> | <DPNF-ID> | <Owner-ID> | <Beneficiary-ID> | <Nonce>
    (deftable AQP|T|BenDptfTotal:{AcquisitionSchemasV1.AQP|BenDptfTotal})                    ;;8] Key = <Beneficiary-ID> | <DPTF-ID>
    (deftable AQP|T|BenDpsfNonceTotal:{AcquisitionSchemasV1.AQP|BenDpsfNonceTotal})          ;;9] Key = <Beneficiary-ID> | <DPSF-ID> | <Nonce>
    (deftable AQP|T|BenDpnfNonceTotal:{AcquisitionSchemasV1.AQP|BenDpnfNonceTotal})          ;;10] Key = <Beneficiary-ID> | <DPNF-ID> | <Nonce>
    (deftable AQP|T|BenDpsfAnkMeta:{AcquisitionSchemasV1.AQP|BenDpsfAnkMeta})                ;;11] Key = <Beneficiary-ID> | <DPSF-ID>
    (deftable AQP|T|BenDpnfAnkMeta:{AcquisitionSchemasV1.AQP|BenDpnfAnkMeta})                ;;12] Key = <Beneficiary-ID> | <DPNF-ID>
    (deftable AQP|T|UserOccupancy:{AcquisitionSchemasV1.AQP|UserOccupancy})                  ;;13] Key = <Pool-ID> | <Beneficiary-ID>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    (defcap AQP|GOV ()
        @doc "Governor capability for the AQP|SC_NAME smart DALOS account (TFT/DPOF/DPDC vault send and receive). \
            \ Composed only from this module — never compose AQP-ANK.AQP|GOV cross-module."
        true
    )
    ;;{C3}  Composed
    (defcap AQP|C>ISSUE-POOL
        (executor:string pool-name:string asset-id:string aqp-class:integer)
        @doc "Issue one acquisition pool (single @event). Validates pool-name, class, and asset-id; \
            \ enforces canonical asset ownership from aqp-class + asset-id; composes SECURE for XI_IssuePool."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
            )
            ;;1] pool-name is a valid autostake index (unique pool id stem)
            (ref-U|ATS::UEV_AutostakeIndex pool-name)
            ;;2] aqp-class in 0..4 and asset-id matches class rules (native id, not a special prefix)
            (UEV_IssuePoolClassAndAsset aqp-class asset-id)
            ;;3] tx sender must own the canonical asset behind this pool class + asset-id
            (CAP_AqpAssetOwner aqp-class asset-id)
            (UEV_ExecutorIzAqpAssetOwner executor aqp-class asset-id)
            (compose-capability (SECURE))
        )
    )
    (defcap AQP|C>ADD-SCORE
        (executor:string pool-id:string score-id:string slot-index:integer)
        @doc "Assign score-id to score slot slot-index (first free; computed once in C_AddScore). Validates \
            \ slot claim, pool/score pairing; CAP_PoolOwner. Score owner in SCR|XE>CREATE-AQPOOL-LINK on XE. \
            \ Composes SECURE for XI_AddScoreToPool."
        @event
        (UEV_AddScorePoolAndScore pool-id score-id slot-index)
        (CAP_PoolOwner pool-id)
        (UEV_ExecutorIzPoolOwner executor pool-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|C>REVOKE-SCORE
        (executor:string pool-id:string score-id:string slot-index:integer)
        @doc "Revoke score-id from score slot slot-index (computed once in C_RevokeScore). Validates \
            \ slot claim, zero totals, fvt-link BAR, boost-link dependents; CAP_PoolOwner. Score owner in \
            \ SCR|XE>REVOKE-AQPOOL-LINK on XE. Composes SECURE for XI_RevokeScoreFromPool."
        @event
        (UEV_RevokeScorePoolAndScore pool-id score-id slot-index)
        (CAP_PoolOwner pool-id)
        (UEV_ExecutorIzPoolOwner executor pool-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|C>DISABLE-POOL-STAKE
        (executor:string pool-id:string)
        @doc "Pool owner pauses new stakes (stake-enabled → false). Idempotent when already false. \
            \ Unstake and vacate are unaffected."
        @event
        (CAP_PoolOwner pool-id)
        (UEV_ExecutorIzPoolOwner executor pool-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|C>ENABLE-POOL-STAKE
        (executor:string pool-id:string)
        @doc "Pool owner re-enables new stakes (stake-enabled → true). BLOCKED while a vacate session is in \
            \ progress — the owner must finish the vacate or C_AbortVacate first (audit H2 / fix #5). \
            \ Idempotent when already true; admission still requires ≥1 employed score and FVT pipeline ready."
        @event
        (enforce
            (not (UR_AQP|PoolVacateInProgress pool-id))
            "Cannot enable pool stake while a vacate is in progress; finish or abort the vacate first"
        )
        (CAP_PoolOwner pool-id)
        (UEV_ExecutorIzPoolOwner executor pool-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Forward-only (FVT::CC_TrueFungibleStakeFlow phase 1]): validation for XE_TrueFungibleTransfer. \
            \ Pool/beneficiary/tracker/rollup rules here; dptf-id/amount/debit via TFT::C_Transfer. \
            \ CAP_StakeOwner (owner wallet); compose P|AQP|CALLER (TFT IMC); compose AQP|GOV (AQP|SC_NAME smart account — \
            \ send and receive both require governor proof). XI_* writers have no enforce. Not @event — P|UEV_IMC on XE entry."
        (let
            (
                (staked-bal:decimal (UR_AQP|DPTFTrackerBalance pool-id dptf-id owner-id beneficiary-id))
                (rollup-bal:decimal (UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
                (class-ok:bool (URC_StakeTrueFungiblePoolClassOk pool-id))
                (stake-admission-ok:bool (if direction (URC_PoolStakeAdmissionOk pool-id) (URC_PoolUnstakeAdmissionOk pool-id)))
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
        @doc "Forward-only (FVT::CC_OrtoFungibleStakeFlow phase 1]): validation for XE_OrtoFungibleTransfer. \
            \ Whole-nonce DPOF::C_Transfer only. CAP_StakeOwner; compose P|AQP|CALLER + AQP|GOV for vault custody."
        (let
            (
                (stake-admission-ok:bool (if direction (URC_PoolStakeAdmissionOk pool-id) (URC_PoolUnstakeAdmissionOk pool-id)))
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
                        (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
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
        @doc "Forward-only (FVT::CC_CollectableStakeFlow phase 1]): DPDC::C_Transfer + tracker validation. \
            \ son=true DPSF (class-3 pool); son=false DPNF (class-4 pool)."
        (let
            (
                (stake-admission-ok:bool (if direction (URC_PoolStakeAdmissionOk pool-id) (URC_PoolUnstakeAdmissionOk pool-id)))
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
                        (ref-DPDC:module{DpdcV2} DPDC)
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
        @doc "Backward-only (FVT::CC_TrueFungibleStakeFlow phase 2.2]): stamp last-ank-sync-count on BenDptfTotal. \
            \ beneficiary/dptf validation here; full stake rules in FVT|C>TRUE-FUNGIBLE-STAKE-FLOW. \
            \ Composes SECURE for XE write body. Not @event — P|UEV_IMC on XE entry."
        (UEV_StakeBeneficiaryAccount beneficiary-id)
        (UEV_StakeTrueFungibleDptfLeg dptf-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|C>UPDATE-SCORE-MULTIPLIERS
        (patron:string executor:string score-id:string mx-frozen:decimal mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Re-set a score's frozen/sleeping multipliers. THE EMPTINESS GATE LIVES HERE because \
            \ this is the only module that can see both the pool tracker and the score: AQP-SCORE \
            \ deploys first and cannot read this tracker at all. Ownership, fee validity and the \
            \ ordering invariant are enforced by the callee's own capability, which is where they \
            \ belong — each layer proves what it can see. Patron pays IGNIS; composes SECURE."
        @event
        ;;THE EXECUTOR IS BOUND, not merely declared. `CAP_EnforceAccountOwnership` in the callee
        ;;proves somebody signed for the score's OWNER, but the owner is a DERIVED account that
        ;;names no actor (HANDOFF 4g) — without this the caller could put any name in the
        ;;`executor` slot and the emitted event would implicate an account that never took part.
        ;;`UEV_ExecutorIzScoreOwner` does this inside AQP-SCORE but is not interface-declared, so
        ;;the same binding is made here from the reader that is.
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
            )
            (enforce
                (= executor (ref-SCR::UR_SCR|ScoreOwnerKonto score-id))
                "executor must be the score owner"
            )
        )
        ;;THE EMPTINESS GATE IS ENFORCED IN THE CLIENT BODY (`UEV_AQP|ScoreMxChangeSafe`), which
        ;;binds its tracker scan before enforcing it -- a scan cannot be an `enforce` ARGUMENT
        ;;anywhere, defcap or not. Kept out here so the heavy read is visible at the call site.
        (compose-capability (SECURE))
    )
    (defcap AQP|C>BACKFILL-SCORE-SLICE
        (patron:string pool-id:string score-id:string beneficiaries:[string])
        @doc "One fed slice of the re-rate sweep: drive each listed holder's stored base to the \
            \ canonical target for (pool-id, score-id). Patron pays IGNIS; composes SECURE. \
            \ \
            \ PERMISSIONLESS, LIKE THE ANCHOR SYNCS BESIDE IT, and that is a safety argument rather \
            \ than a convenience. The slice cannot express a wrong outcome: it carries no amounts \
            \ and no deltas, only WHICH ACCOUNTS to recompute, and the figure written is derived \
            \ from the live tracker inside the transaction. So the worst a hostile caller achieves \
            \ is paying IGNIS to make the chain MORE correct, while the pool stays repairable even \
            \ if its owner never returns. Gating it on the owner would buy nothing and could strand \
            \ a pool whose scores are provably mis-rated. \
            \ \
            \ NO MEMBERSHIP CHECK ON THE SLICE, DELIBERATELY. A listed account that is already \
            \ correctly rated computes a delta of 0.0 and writes nothing, so a stale slice, an \
            \ overlapping slice and a REPEATED account are all harmless — the target is recomputed \
            \ immediately before each write, never batched ahead of the writes. That is the same \
            \ property that makes two slices order-independent, and it is why this needs no job \
            \ state: `URHC_AQP|ScoreBackfillOutstanding` reading [] is the completion record. \
            \ \
            \ THE ONE THING IT REFUSES is a score whose base is not Σ(amount × mx) at all \
            \ (`URC_AQP|ScoreBackfillSupported`). There the formula itself is wrong, so every delta \
            \ would be invented — and unlike a stale slice, that does not converge to anything."
        @event
        (enforce
            (> (length beneficiaries) 0)
            "Empty slice"
        )
        (enforce
            (URC_AQP|ScoreBackfillSupported pool-id score-id)
            "Score is not re-ratable: it must be a class-0 LP score employed by this pool and not an additive satellite"
        )
        (compose-capability (SECURE))
    )
    (defcap AQP|C>BEGIN-SCORE-REVOKE
        (patron:string executor:string pool-id:string score-id:string slot-index:integer)
        @doc "Phase 1 of 3 — vacate the score's POOL SLOT and freeze the pool for the drain. \
            \ Pool owner only; patron pays IGNIS; composes SECURE. \
            \ \
            \ VACATING THE SLOT IS WHAT MAKES THE DRAIN LEGAL, and it is deliberately the only \
            \ state this phase changes. A score that is LINKED to a pool but holds no SLOT is \
            \ exactly 'being retired': it no longer scores anything new (it is out of \
            \ `URC_PoolActiveScoreIds`, so no stake credits it), while the link that survives is \
            \ what still identifies the pool its orphaned rows belong to. That one bit of \
            \ asymmetry is the pending-revoke marker -- which is why this needs no new column and \
            \ no migration. \
            \ \
            \ THE POOL FREEZES because the drain and the stake path would otherwise write the same \
            \ score rows from both ends: a stake crediting a score mid-drain would re-create the \
            \ weight the drain just retired, and the sweep would never converge."
        @event
        (UEV_BeginScoreRevoke pool-id score-id slot-index)
        (CAP_PoolOwner pool-id)
        (UEV_ExecutorIzPoolOwner executor pool-id)
        (compose-capability (SECURE))
    )
    (defcap AQP|C>DRAIN-SCORE-SLICE
        (patron:string pool-id:string score-id:string accounts:[string])
        @doc "Phase 2 of 3 — retire one SLICE of the holders of a score this pool has stopped \
            \ employing. Patron pays IGNIS; composes SECURE. \
            \ \
            \ THE GATE IS 'NOT SLOTTED, STILL LINKED', and both halves matter. Not slotted proves \
            \ the owner has begun a revoke, so this cannot zero weight in a live score. Still \
            \ linked proves the rows belong to THIS pool, so a caller cannot aim the drain at an \
            \ unrelated pair. The score-side capability re-checks the link from its own tables; \
            \ this checks the slot, which only this module can see. \
            \ \
            \ PERMISSIONLESS, for the same reason the re-rate sweep is: the slice carries no \
            \ figures, only WHICH ACCOUNTS to retire, and the target is 0.0 by definition. There is \
            \ no wrong outcome a hostile caller can express -- only IGNIS they can waste -- and a \
            \ pool whose owner vanishes mid-revoke stays finishable by anyone."
        @event
        (enforce
            (> (length accounts) 0)
            "Empty slice"
        )
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
            )
            (enforce
                (and
                    (not (contains score-id (URC_PoolActiveScoreIds pool-id)))
                    (= (ref-SCR::UR_SCR|ScoreAqpoolLink score-id) pool-id)
                )
                "Score is not mid-revoke on this pool: it must be unslotted but still linked"
            )
        )
        (compose-capability (SECURE))
    )
    (defcap AQP|C>FINALIZE-SCORE-REVOKE
        (patron:string executor:string pool-id:string score-id:string)
        @doc "Phase 3 of 3 — cut the aqpool-link once the drain is provably complete. Pool owner; \
            \ patron pays IGNIS; composes SECURE. \
            \ \
            \ COMPLETENESS IS MEASURED, NOT ASSERTED. The gate re-reads the drain's own work list \
            \ and refuses while a single holder remains, so the link cannot be cut over weight that \
            \ still exists. A client that trusted a caller's 'done' flag would strand exactly the \
            \ rows nothing can find afterwards -- with the link gone, even the orphan scan loses \
            \ the pool it belonged to."
        @event
        ;;COMPLETENESS IS ENFORCED IN THE CLIENT BODY (`UEV_AQP|ScoreDrainComplete`), which binds
        ;;its user-score scan before enforcing it. Authorisation stays here, where it belongs.
        (CAP_PoolOwner pool-id)
        (UEV_ExecutorIzPoolOwner executor pool-id)
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
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Bar:string
        ()
        @doc "Returns CT_BAR constant."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    (defun CT_EmptyCumulator ()
        @doc "Empty IGNIS OutputCumulator for stub transfer legs."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    (defun CT_AqpScName:string
        ()
        @doc "Resolves AQP|SC_NAME from canonical AQP-ANK via interface ref."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (ref-ANK::GOV|AQP|SC_NAME)
        )
    )
    ;;
    ;; [UDC] construct
    ;;
    ;; Default tracker and attribution rows for UR with-default-read.
    (defun UDC_AQP|TrueFungibleTracker:object{AcquisitionSchemasV1.AQP|TrueFungibleTracker}
        (bal:decimal pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Default DPTF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dptf-id"          : dptf-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id}
    )
    (defun UDC_AQP|OrtoFungibleTracker:object{AcquisitionSchemasV1.AQP|OrtoFungibleTracker}
        (bal:decimal pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Default DPOF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dpof-id"          : dpof-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|SemiFungibleTracker:object{AcquisitionSchemasV1.AQP|SemiFungibleTracker}
        (bal:decimal pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Default DPSF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dpsf-id"          : dpsf-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|NonFungibleTracker:object{AcquisitionSchemasV1.AQP|NonFungibleTracker}
        (bal:decimal pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Default DPNF tracker row (zero balance, key fields from arguments)."
        {"balance"          : bal
        ,"pool-id"          : pool-id
        ,"dpnf-id"          : dpnf-id
        ,"owner-id"         : owner-id
        ,"beneficiary-id"   : beneficiary-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|BenDptfTotal:object{AcquisitionSchemasV1.AQP|BenDptfTotal}
        (total:decimal sync-count:integer beneficiary-id:string dptf-id:string)
        @doc "Default beneficiary DPTF rollup row (zero total, never synced)."
        {"total-balance"        : total
        ,"last-ank-sync-count"  : sync-count
        ,"beneficiary-id"       : beneficiary-id
        ,"dptf-id"              : dptf-id}
    )
    (defun UDC_AQP|BenDpsfNonceTotal:object{AcquisitionSchemasV1.AQP|BenDpsfNonceTotal}
        (amount:integer beneficiary-id:string dpsf-id:string nonce:integer)
        @doc "Default DPSF per-nonce rollup row (zero amount)."
        {"amount"           : amount
        ,"beneficiary-id"   : beneficiary-id
        ,"dpsf-id"          : dpsf-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|BenDpnfNonceTotal:object{AcquisitionSchemasV1.AQP|BenDpnfNonceTotal}
        (amount:integer beneficiary-id:string dpnf-id:string nonce:integer)
        @doc "Default DPNF per-nonce rollup row (zero amount)."
        {"amount"           : amount
        ,"beneficiary-id"   : beneficiary-id
        ,"dpnf-id"          : dpnf-id
        ,"nonce"            : nonce}
    )
    (defun UDC_AQP|BenDpsfAnkMeta:object{AcquisitionSchemasV1.AQP|BenDpsfAnkMeta}
        (sync-count:integer active-nonce-count:integer beneficiary-id:string dpsf-id:string)
        @doc "Default DPSF ANK meta row (never synced, no active nonces)."
        {"last-ank-sync-count"  : sync-count
        ,"active-nonce-count"   : active-nonce-count
        ,"beneficiary-id"       : beneficiary-id
        ,"dpsf-id"              : dpsf-id}
    )
    (defun UDC_AQP|BenDpnfAnkMeta:object{AcquisitionSchemasV1.AQP|BenDpnfAnkMeta}
        (sync-count:integer active-nonce-count:integer beneficiary-id:string dpnf-id:string)
        @doc "Default DPNF ANK meta row (never synced, no active nonces)."
        {"last-ank-sync-count"  : sync-count
        ,"active-nonce-count"   : active-nonce-count
        ,"beneficiary-id"       : beneficiary-id
        ,"dpnf-id"              : dpnf-id}
    )
    (defun UDC_AQP|UserOccupancy:object{AcquisitionSchemasV1.AQP|UserOccupancy}
        (unn:integer pool-id:string beneficiary-id:string)
        @doc "Vacate-v2 §4: default per (pool, beneficiary) occupancy row (unn = 0 when absent)."
        {"unn"                  : unn
        ,"pool-id"              : pool-id
        ,"beneficiary-id"       : beneficiary-id}
    )
    (defun UDC_AQP|Schema:object{AcquisitionSchemasV1.AQP|Schema}
        (aqp-class:integer asset-id:string aqp-id:string)
        @doc "Default new pool row: all seven score slots BAR; aqp-id equals pool-id (table key). #FP1 universal \
            \ nns: starts -1 only for LP pools (class 0, complex multi-leg — still nzs-based finalize) and 0 for \
            \ occupancy-tracked pools (class 1 TF legs, 2/3/4 OF/SF/NF nonce positions)."
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
        ,"nns"                  : (if (< aqp-class 1) -1 0)
        ,"aqp-id"               : aqp-id}
    )
    (defun UDC_AQP|SchemaWithScoreSlots:object{AcquisitionSchemasV1.AQP|Schema}
        (pool:object{AcquisitionSchemasV1.AQP|Schema}
            score-primary:string
            score-secondary:string
            score-tertiary:string
            score-quaternary:string
            score-quinary:string
            score-senary:string
            score-septenary:string
        )
        @doc "Returns pool row with all seven score slots replaced (merge over the existing row)."
        ;;MERGE ORDER FIX (2026-09-13). This was `(+ pool {…seven slots…})` and was therefore a
        ;;COMPLETE NO-OP: Pact's object `+` gives precedence to the LEFT operand on key collisions
        ;;-- verified live, `(+ {"a": 1, "b": 9} {"a": 2, "c": 3})` is `{"a": 1, "b": 9, "c": 3}`.
        ;;The pool row already carries all seven slot keys, so every supplied value was discarded and
        ;;the function returned its input unchanged, flatly contradicting its own @doc ("all seven
        ;;score slots replaced").
        ;;
        ;;Caught by writing the first test this function has ever had: addressing slot N and reading
        ;;back slot N returned the row's ORIGINAL score, not the one just written.
        ;;
        ;;NO BLAST RADIUS, which is why this is a repair rather than a deletion: its only caller is
        ;;`UDC_AQP|SchemaWithScoreAtSlot` directly below, and THAT has no callers anywhere in the
        ;;codebase. Neither is on the AcquisitionPoolsV1 interface, so no cascade. The live slot
        ;;writer is a different mechanism entirely -- `UC_PoolScoreSlotPatch` builds a PARTIAL update
        ;;map consumed by `WU_Pool|ScoreSlot`, which is correct and unaffected.
        ;;Pinned slot-by-slot by REPL/modules/AQP.repl <<AQP-F10>>.
        (+  {"score-primary"    : score-primary
            ,"score-secondary"  : score-secondary
            ,"score-tertiary"   : score-tertiary
            ,"score-quaternary" : score-quaternary
            ,"score-quinary"    : score-quinary
            ,"score-senary"     : score-senary
            ,"score-septenary"  : score-septenary}
            pool
        )
    )
    (defun UDC_AQP|SchemaWithScoreAtSlot:object{AcquisitionSchemasV1.AQP|Schema}
        (pool:object{AcquisitionSchemasV1.AQP|Schema} slot-index:integer score-id:string)
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
    ;;{5.2}  Compute [UC]
    ;; [UC]  compute
    (defun UCk_DPTFTracker:string (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Composite key for AQP|T|DPTFTracker: pool-id | dptf-id | owner-id | beneficiary-id."
        (concat [pool-id BAR dptf-id BAR owner-id BAR beneficiary-id])
    )
    (defun UCk_DPOFTracker:string (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Composite key for AQP|T|DPOFTracker: pool-id | dpof-id | owner-id | beneficiary-id | nonce."
        (concat [pool-id BAR dpof-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce])])
    )
    (defun UCk_DPSFTracker:string (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Composite key for AQP|T|DPSFTracker: pool-id | dpsf-id | owner-id | beneficiary-id | nonce."
        (concat [pool-id BAR dpsf-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce])])
    )
    (defun UCk_DPNFTracker:string (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Composite key for AQP|T|DPNFTracker: pool-id | dpnf-id | owner-id | beneficiary-id | nonce."
        (concat [pool-id BAR dpnf-id BAR owner-id BAR beneficiary-id BAR (format "{}" [nonce])])
    )
    (defun UCk_BenDptfTotal:string (beneficiary-id:string dptf-id:string)
        @doc "Composite key for AQP|T|BenDptfTotal: beneficiary-id | dptf-id."
        (concat [beneficiary-id BAR dptf-id])
    )
    (defun UCk_BenDpsfNonceTotal:string (beneficiary-id:string dpsf-id:string nonce:integer)
        @doc "Composite key for AQP|T|BenDpsfNonceTotal: beneficiary-id | dpsf-id | nonce."
        (concat [beneficiary-id BAR dpsf-id BAR (format "{}" [nonce])])
    )
    (defun UCk_BenDpnfNonceTotal:string (beneficiary-id:string dpnf-id:string nonce:integer)
        @doc "Composite key for AQP|T|BenDpnfNonceTotal: beneficiary-id | dpnf-id | nonce."
        (concat [beneficiary-id BAR dpnf-id BAR (format "{}" [nonce])])
    )
    (defun UCk_BenDpsfAnkMeta:string (beneficiary-id:string dpsf-id:string)
        @doc "Composite key for AQP|T|BenDpsfAnkMeta: beneficiary-id | dpsf-id."
        (concat [beneficiary-id BAR dpsf-id])
    )
    (defun UCk_BenDpnfAnkMeta:string (beneficiary-id:string dpnf-id:string)
        @doc "Composite key for AQP|T|BenDpnfAnkMeta: beneficiary-id | dpnf-id."
        (concat [beneficiary-id BAR dpnf-id])
    )
    (defun UCk_UserOccupancy:string (pool-id:string beneficiary-id:string)
        @doc "Composite key for AQP|T|UserOccupancy: pool-id | beneficiary-id."
        (concat [pool-id BAR beneficiary-id])
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
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [UR]  read
    (defun UR_AQP|Pool:object{AcquisitionSchemasV1.AQP|Schema} (pool-id:string)
        @doc "Reads full pool definition row from AQP|T|Pool."
        (read AQP|T|Pool pool-id)
    )
    (defun UR_AQP|PoolAqpClass:integer (pool-id:string)
        @doc "Reads aqp-class from pool row."
        (at "aqp-class" (read AQP|T|Pool pool-id ["aqp-class"]))
    )
    (defun URC_AQP|ScoreMxChangeSafe:bool (score-id:string)
        @doc "HEAVY (two tracker scans). True iff this score has NO frozen and NO sleeping position, \
            \ which is exactly the condition under which its multipliers may be re-set without \
            \ corrupting anybody's weight. \
            \ \
            \ WHY NOT `nzs-count = 0`, the obvious gate: it is the count of holders with ANY weight, \
            \ so a score with ordinary native stakers fails it — and on the live chain that is \
            \ SilverSnakePower, with three native holders, the score most in need of the change. \
            \ Native stakes multiply by 1.0 and never read `mx` \
            \ (`URC_SignedBaseDeltaForDptfLpStake`), so they are not what makes a change unsafe. \
            \ The frozen and sleeping LEGS are. \
            \ \
            \ WHAT MAKES A CHANGE UNSAFE is not staleness. The base is an accumulated SIGNED delta \
            \ that promises 'a full unstake reverses exactly and nets to 0'; change `mx` between a \
            \ stake and its unstake and the reversal stops cancelling, the row can go NEGATIVE and \
            \ the global total with it. Deb-staleness never compares `mx`, so nothing reports it. \
            \ \
            \ TEMPORARY. The owner's standing decision is that a change triggers a parallel re-rate \
            \ sweep instead of being refused. When that sweep lands, this predicate stops being a \
            \ gate and becomes the test for whether the sweep is NEEDED."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                ;;
                (pool-id:string (ref-SCR::UR_SCR|ScoreAqpoolLink score-id))
            )
            ;;A COLLECTION POOL HAS NO DPTF ASSET, AND READING ONE ABORTS. aqp-class 3 (DPSF) and
            ;;4 (DPNF) hold a collection, which has no row in `DPTF|PropertiesTable` -- so the bare
            ;;`UR_Frozen` below does not return a default, it ABORTS the whole transaction with
            ;;"No value found in table ... for key: DHB-...". Measured 2026-10-10 against mainnet:
            ;;ELEVEN of the fifteen live scores failed this way, which made
            ;;`CC_UpdateScoreMultipliers` unusable for every collection score and reported it with
            ;;a message naming neither the score nor the cause.
            ;;
            ;;TRUE IS THE CORRECT ANSWER, not merely the safe one: freezing and sleeping are
            ;;variants of a FUNGIBLE. An asset that has no DPTF properties cannot have a frozen or
            ;;sleeping DPTF leg, so there is nothing a multiplier change could mis-rate.
            (if (or (= pool-id BAR) (> (UR_AQP|PoolAqpClass pool-id) 2))
                true
                (let
                    (
                        (asset:string (UR_AQP|PoolAssetId pool-id))
                    )
                    (let
                        (
                            (frozen:string (ref-DPTF::UR_Frozen asset))
                            (sleeping:string (ref-DPTF::UR_Sleeping asset))
                        )
                        (and
                            (if (= frozen BAR) true
                                (= (length (URH_AQP|ActiveDptfTrackerRows pool-id frozen)) 0))
                            (if (= sleeping BAR) true
                                (= (length (URH_AQP|ActiveDpofTrackerRows pool-id sleeping)) 0)))
                    )
                )
            )
        )
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
    (defun UR_AQP|PoolNns:integer (pool-id:string)
        @doc "#FP1: reads the pool nns occupancy counter — -1 for amount pools (class 0/1); for nonce pools \
            \ (class 2/3/4) the number of occupied nonce positions (0 = tracker empty, the finalize oracle)."
        (at "nns" (read AQP|T|Pool pool-id ["nns"]))
    )
    (defun UR_AQP|UserUnn:integer (pool-id:string beneficiary-id:string)
        @doc "Vacate-v2 §4: reads the (pool, beneficiary) occupancy counter — occupied tracker positions for \
            \ this beneficiary (0 when absent). The fast-vacate drain settles a beneficiary the moment this \
            \ decrements to 0 (their last position drained)."
        (with-default-read AQP|T|UserOccupancy (UCk_UserOccupancy pool-id beneficiary-id)
            {"unn" : 0} {"unn" := u} u)
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
    (defun UR_AQP|DPTFTracker:object{AcquisitionSchemasV1.AQP|TrueFungibleTracker}
        (pool-id:string dptf-id:string owner-id:string beneficiary-id:string)
        @doc "Reads DPTF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPTFTracker (UCk_DPTFTracker pool-id dptf-id owner-id beneficiary-id)
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
    (defun UR_AQP|BenDptfTotal:object{AcquisitionSchemasV1.AQP|BenDptfTotal}
        (beneficiary-id:string dptf-id:string)
        @doc "Reads cross-pool DPTF stake rollup for beneficiary × dptf-id; absent row reads as zero total."
        (with-default-read AQP|T|BenDptfTotal (UCk_BenDptfTotal beneficiary-id dptf-id)
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
    (defun UR_AQP|BenDpsfNonceTotal:object{AcquisitionSchemasV1.AQP|BenDpsfNonceTotal}
        (beneficiary-id:string dpsf-id:string nonce:integer)
        @doc "Reads cross-pool per-nonce DPSF rollup; absent row reads as zero amount."
        (with-default-read AQP|T|BenDpsfNonceTotal
            (UCk_BenDpsfNonceTotal beneficiary-id dpsf-id nonce)
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
    (defun UR_AQP|BenDpsfAnkMeta:object{AcquisitionSchemasV1.AQP|BenDpsfAnkMeta}
        (beneficiary-id:string dpsf-id:string)
        @doc "Reads ANK sync metadata for one DPSF leg; absent row reads as never synced / no active nonces."
        (with-default-read AQP|T|BenDpsfAnkMeta
            (UCk_BenDpsfAnkMeta beneficiary-id dpsf-id)
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
    (defun UR_AQP|BenDpnfNonceTotal:object{AcquisitionSchemasV1.AQP|BenDpnfNonceTotal}
        (beneficiary-id:string dpnf-id:string nonce:integer)
        @doc "Reads cross-pool per-nonce DPNF rollup; absent row reads as zero amount."
        (with-default-read AQP|T|BenDpnfNonceTotal
            (UCk_BenDpnfNonceTotal beneficiary-id dpnf-id nonce)
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
    (defun UR_AQP|BenDpnfAnkMeta:object{AcquisitionSchemasV1.AQP|BenDpnfAnkMeta}
        (beneficiary-id:string dpnf-id:string)
        @doc "Reads ANK sync metadata for one DPNF leg; absent row reads as never synced / no active nonces."
        (with-default-read AQP|T|BenDpnfAnkMeta
            (UCk_BenDpnfAnkMeta beneficiary-id dpnf-id)
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
    (defun UR_AQP|DPOFTracker:object{AcquisitionSchemasV1.AQP|OrtoFungibleTracker}
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads DPOF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPOFTracker (UCk_DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce)
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
    (defun UR_AQP|DPSFTracker:object{AcquisitionSchemasV1.AQP|SemiFungibleTracker}
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads DPSF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPSFTracker (UCk_DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce)
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
    (defun UR_AQP|DPNFTracker:object{AcquisitionSchemasV1.AQP|NonFungibleTracker}
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer)
        @doc "Reads DPNF tracker row; absent rows read as zero balance via default object."
        (with-default-read AQP|T|DPNFTracker (UCk_DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce)
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
    (defun URC_AqpOwnerKontoFromClassAndAsset:string (aqp-class:integer asset-id:string)
        @doc "Resolve pool governor konto from aqp-class and canonical native asset-id (issue-time or pre-pool-row)."
        (let
            (
                (ref-SWP:module{SwapperV4} SWP)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-DPDC:module{DpdcV2} DPDC)
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
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
    (defun URC_PoolUnstakeAdmissionOk:bool (pool-id:string)
        @doc "True when the UNSTAKE direction is allowed: the pool must be neither vacate-in-progress \
            \ NOR sweep-in-progress. A vacate session (begin→finalize) force-unwinds every staker \
            \ itself, so a concurrent user-initiated unstake would race the same tracker/aggregate \
            \ rows the drain writes — freeze it until finalize. (Unlike stake admission, this does \
            \ NOT require stake-enabled or employed scores — exiting a disabled/empty pool stays \
            \ allowed.) \
            \ \
            \ UNSTAKE IS NOW BLOCKED MID-SWEEP TOO, and it was not before — stake admission has \
            \ carried the sweep guard since D3 while this direction only ever checked vacate. The \
            \ asymmetry was wrong in a way that only a re-rate makes reachable: a sweep exists \
            \ precisely because stored weights DISAGREE with their canonical targets, and an \
            \ unstake reverses the STORED figure. Exiting mid-sweep therefore reverses a number \
            \ the chain has already decided is wrong, and the residue it leaves behind is \
            \ unrecoverable — the position is gone, so no later sweep can recompute what it \
            \ should have been. Blocking the exit is the only way the reversal stays exact. \
            \ \
            \ The freeze is never a trap: every sweep that sets it is PERMISSIONLESS to run and \
            \ `CC_ClearPoolSweep` is permissionless to call, so a holder who wants out can finish \
            \ the work themselves rather than wait for an admin."
        (and
            (not (UR_AQP|PoolVacateInProgress pool-id))
            (not (UR_AQP|PoolSweepInProgress pool-id))
        )
    )
    (defun URC_StakeTrueFungiblePoolClassOk:bool (pool-id:string)
        @doc "True when pool aqp-class is 0 (LP via TF) or 1 (non-LP DPTF)."
        (let
            (
                (c:integer (UR_AQP|PoolAqpClass pool-id))
            )
            (or (= c 0) (= c 1))
        )
    )
    (defun URC_StakeOrtoFungiblePoolClassOk:bool (pool-id:string)
        @doc "True when pool aqp-class is 0 (LP + Z| orto), 1 (DPTF + sleep/hib DPOF satellites), or 2 (native DPOF)."
        (let
            (
                (c:integer (UR_AQP|PoolAqpClass pool-id))
            )
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
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
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
            ["vacate-in-progress"])
    )
    ;; [URH] heavy-read
    ;; WU_BenDpnfAnkMeta|BeneficiaryId — select key; WU not needed.
    ;; WU_BenDpnfAnkMeta|DpnfId — select key; WU not needed.
    ;;
    ;; Reads follow schema order: (1) AQP|Schema (2) TrueFungibleTracker (2b) BenDptfTotal \
    ;;     (2c) BenDpsf* + BenDpnf* rollups \
    ;;     (3) OrtoFungibleTracker (4) SemiFungibleTracker (5) NonFungibleTracker
    ;;
    (defun URH_AQP|AllPoolIds:[string] ()
        @doc "Returns all row keys from AQP|T|Pool."
        (keys AQP|T|Pool)
    )
    (defun URH_AQP|BenDpsfActiveNonceSupplies:[object] (beneficiary-id:string dpsf-id:string)
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
    (defun URH_AQP|BenDpnfActiveNonceSupplies:[object] (beneficiary-id:string dpnf-id:string)
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
    (defun URH_AQP|ActiveDptfTrackerRows:[object] (pool-id:string dptf-id:string)
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
    (defun URH_AQP|ActiveDpofTrackerRows:[object] (pool-id:string dpof-id:string)
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
    (defun URH_AQP|ActiveDpsfTrackerRows:[object] (pool-id:string dpsf-id:string)
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
    (defun URH_AQP|ActiveDpnfTrackerRows:[object] (pool-id:string dpnf-id:string)
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
    ;; ── RE-RATE / BACK-FILL ENGINE ─────────────────────────────────────────────
    ;; One question, asked four ways: WHAT BASE SHOULD THIS HOLDER HAVE RIGHT NOW?
    ;;
    ;;   target(holder) = floor(Σn × 1.0, p) + floor(Σf × mx-frozen, p) + Σ ledger(sleeping slots)
    ;;
    ;; The stored base is a MAINTAINED SIGNED ACCUMULATOR -- every stake adds a delta, every
    ;; unstake subtracts one, and nothing ever recomputes across holders. That is what makes the
    ;; system cheap, and it is why several separate problems reduce to this one function:
    ;;
    ;;   1] A SCORE WAS ADDED to a pool that already had stakers: every target is non-zero while
    ;;      every base is 0. (The owner's bunny-pool question.)
    ;;   2] A SCORE WAS REVOKED, or a row was ORPHANED: base non-zero, target 0.
    ;;   3] ROUNDING DRIFT from a position staked in several tranches and withdrawn in one.
    ;;
    ;; NOTE WHAT IS *NOT* ON THAT LIST ANY MORE: a maturing sleeping batch. Its weight is derived
    ;; from the STORED TERM in `SCR|T|SleepStake` -- how much of the lock the nonce had left when
    ;; it was staked -- and never from the live clock, because a sleeping multiplier is fixed at
    ;; STAKE time. The term is what is stored, not the weight: a term is ceiling-INDEPENDENT, so
    ;; ONE row per nonce serves all of a pool's scores, each re-deriving its own figure at its own
    ;; precision (`URC_SCR|SleepingLegHeldWeight`).
    ;; A target that re-derived it from today's multiplier would drag the base away from the
    ;; figure the unstake will reverse, and once the position is gone that gap is unrecoverable.
    ;; A sleeping holder's weight is therefore meant to hold still: they already committed what
    ;; they committed, and because the rate was set by REMAINING time there was never anything to
    ;; gamble. Changing a score's mx CEILING does not retroactively move them either; re-rating
    ;; an existing ledger to a new ceiling is deliberately separate work.
    ;;
    ;; APPLIED AS A DELTA, NEVER AS AN ABSOLUTE WRITE -- `target - current` goes through
    ;; `SCR::XE_ApplyRawBaseDelta`, the same writer every stake uses, so the user row, the score's
    ;; vault totals and `nzs-count` stay maintained by ONE piece of code. The alternative (a second
    ;; writer that sets the base directly) would have to reproduce all three and would be free to
    ;; disagree with the first.
    ;;
    ;; IDEMPOTENT, ORDER-INDEPENDENT, AND SELF-CHECKING. A slice recomputes the target from the
    ;; tracker, so a replayed slice computes delta 0 and writes nothing; two disjoint slices touch
    ;; disjoint user rows and compose into a shared total by += ; and `URHC_AQP|ScoreBackfillOutstanding`
    ;; returning [] IS the proof that no sweep is needed. No job state, no cursor: the live table is
    ;; the completion ledger. This is a FED SLICE, the parallel-safe recipe shape.
    (defun UC_AQP|BackfillUniqueBeneficiaries:[string] (rows:[object])
        @doc "First-seen-order dedupe of `beneficiary-id` across tracker rows. \
            \ ONE BENEFICIARY MAY HOLD THROUGH MANY OWNERS and across all three legs, so the same \
            \ account appears in several rows while owning exactly ONE user-score row. Collapsing \
            \ them is what makes the target one figure per ACCOUNT rather than per row."
        (fold
            (lambda (acc:[string] row:object)
                (let
                    (
                        (b:string (at "beneficiary-id" row))
                    )
                    (if (contains b acc) acc (+ acc [b]))
                )
            )
            []
            rows
        )
    )
    (defun UC_AQP|BackfillRowsForBeneficiary:[object] (beneficiary-id:string rows:[object])
        @doc "The subset of tracker rows crediting one beneficiary."
        (filter
            (lambda (row:object) (= (at "beneficiary-id" row) beneficiary-id))
            rows
        )
    )
    (defun UC_AQP|BackfillSumForBeneficiary:decimal (beneficiary-id:string rows:[object])
        @doc "Σ `balance` over the rows crediting one beneficiary. RAW amount, UNWEIGHTED -- the \
            \ multiplier is applied once to this sum, never per row, because the stake path floors \
            \ ONCE PER CALL and a per-row floor would not reproduce it."
        (fold (+) 0.0
            (map
                (lambda (row:object) (at "balance" row))
                (UC_AQP|BackfillRowsForBeneficiary beneficiary-id rows)
            )
        )
    )
    (defun URC_AQP|PoolLiquidityLegs:object (pool-id:string)
        @doc "The three asset-ids a liquidity pool weighs: the native LP DPTF, its FROZEN DPTF twin \
            \ and its SLEEPING DPOF twin. BAR when the asset declares no such twin, which is what \
            \ the callers branch on -- an absent twin contributes nothing rather than refusing."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (asset:string (UR_AQP|PoolAssetId pool-id))
            )
            {"native"   : asset
            ,"frozen"   : (ref-DPTF::UR_Frozen asset)
            ,"sleeping" : (ref-DPTF::UR_Sleeping asset)}
        )
    )
    (defun URC_AQP|ScoreBackfillSupported:bool (pool-id:string score-id:string)
        @doc "True iff `target = Σ(amount × mx)` is the CORRECT formula for this score's base. \
            \ Everything downstream refuses rather than computes when this is false, because a \
            \ delta derived from the wrong formula does not fail -- it writes a plausible wrong \
            \ number into a maintained accumulator, where it is indistinguishable from a real one. \
            \ \
            \ Three conditions, and the third is the one that is easy to miss: \
            \ \
            \ 1] THE SCORE IS EMPLOYED BY THIS POOL. A (pool, score) pair the chain does not relate \
            \    has no holders and no meaning. \
            \ 2] CLASS 0 OR CLASS 1 -- the two whose base really is `amount × mx`. Class 0 is LP \
            \    via a true fungible, class 1 is a plain DPTF, and their per-leg arithmetic is \
            \    IDENTICAL: `URC_SignedBaseDeltaForDptfStake` and \
            \    `URC_SignedBaseDeltaForDptfLpStake` are both `floor(amount × mx, p)` with mx \
            \    1.0 native / mx-frozen frozen. Pinned equal by [6.2.17] TX-RERATE-04, and the \
            \    target still calls the one matching the class rather than relying on that. \
            \    EXCLUDED: class 2 (DPOF) weighs per-nonce amounts through a DIFFERENT pair of \
            \    functions, and classes 3/4 (SF/NF) weigh per-nonce and per-trait TABLE VALUES \
            \    that are not amounts at all. Supporting class 2 is part of the sleeping-token \
            \    custody work, not this engine. \
            \ 3] NOT AN ADDITIVE SATELLITE. When a score has BOTH a boost-link and a boost-class- \
            \    link, `URC_SingularUserScoreDeltaFromSignedUserBase` pins its stored base at \
            \    EXACTLY 0.0 -- the hub owns the canonical base and the satellite is a boosting row. \
            \    Its target under this formula is non-zero, so without this clause the sweep would \
            \    compute a delta, apply it, read 0.0 back, and report the holder outstanding again \
            \    FOREVER: a sweep that never converges and bills every pass. A satellite needs no \
            \    back-fill of its own; when the HUB's base moves, the satellite's boosted/deb values \
            \    go stale and the EXISTING deb-staleness sweep is what repairs them."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
            )
            (fold (and) true
                [
                    (= (ref-SCR::UR_SCR|ScoreAqpoolLink score-id) pool-id)
                    (contains score-id (URC_PoolActiveScoreIds pool-id))
                    (contains (ref-SCR::UR_SCR|ScoreClass score-id) [0 1])
                    (not
                        (and
                            (!= (ref-SCR::UR_SCR|ScoreBoostLink score-id) BAR)
                            (!= (ref-SCR::UR_SCR|ScoreBoostClassLink score-id) BAR)
                        )
                    )
                ]
            )
        )
    )
    (defun URH_AQP|ScoreTargetBaseForBeneficiary:decimal
        (pool-id:string score-id:string beneficiary-id:string
         nat-rows:[object] frz-rows:[object] slp-rows:[object])
        @doc "The canonical base ONE beneficiary should carry, from pre-scanned tracker rows. \
            \ \
            \ Takes the rows rather than reading them so the three `select`s happen ONCE per \
            \ transaction instead of once per holder. \
            \ \
            \ THE DPTF LEGS ARE RECOMPUTED, THE SLEEPING LEG IS READ. `URC_SignedBaseDeltaFor*` \
            \ are CALLED rather than reimplemented, so there is exactly one copy of the weighting \
            \ rule -- and for native and frozen that recomputation is EXACT, because their \
            \ multipliers never move (1.0 and a flat `mx-frozen`). \
            \ \
            \ The SLEEPING leg is recomputed too, but from the STORED TERM rather than the live \
            \ clock: its multiplier was fixed at STAKE time from the lock's remaining term, and \
            \ `SCR|T|SleepStake` is what remembers that term. Deriving it from today's remaining \
            \ time instead would move the base off the figure the unstake reverses, and once the \
            \ position is gone that gap is unrecoverable. The stake, the unstake and this target \
            \ all call ONE function -- `URC_SCR|SleepingLegHeldWeight` -- so they cannot drift."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (legs:object (URC_AQP|PoolLiquidityLegs pool-id))
                (slp-mine:[object] (UC_AQP|BackfillRowsForBeneficiary beneficiary-id slp-rows))
            )
            (fold (+) 0.0
                [
                    ;;THE LEG FUNCTION FOLLOWS THE SCORE CLASS, not the other way round. The two
                    ;;are the same arithmetic today -- `floor(amount x mx, p)` either way, pinned
                    ;;equal by [6.2.17] TX-RERATE-04 -- so this branch changes no number. It is
                    ;;here because the target must be whatever the STAKE PATH would have written,
                    ;;and the stake path dispatches on class (XE_ApplyTrueFungibleStakeDelta sends
                    ;;class 0 to XI_1|UpdateScoreDataForTrueFungibleLP and everything else to
                    ;;XI_1|UpdateScoreDataForTrueFungible). Calling one function for both would
                    ;;make the engine correct only while the two happen to agree, and silently
                    ;;wrong the day one of them changes.
                    (if (= (ref-SCR::UR_SCR|ScoreClass score-id) 0)
                        (ref-SCR::URC_SignedBaseDeltaForDptfLpStake
                            score-id (at "native" legs)
                            (UC_AQP|BackfillSumForBeneficiary beneficiary-id nat-rows)
                            true true)
                        (ref-SCR::URC_SignedBaseDeltaForDptfStake
                            score-id (at "native" legs)
                            (UC_AQP|BackfillSumForBeneficiary beneficiary-id nat-rows)
                            true true)
                    )
                    (if (= (at "frozen" legs) BAR)
                        0.0
                        (if (= (ref-SCR::UR_SCR|ScoreClass score-id) 0)
                            (ref-SCR::URC_SignedBaseDeltaForDptfLpStake
                                score-id (at "frozen" legs)
                                (UC_AQP|BackfillSumForBeneficiary beneficiary-id frz-rows)
                                false true)
                            (ref-SCR::URC_SignedBaseDeltaForDptfStake
                                score-id (at "frozen" legs)
                                (UC_AQP|BackfillSumForBeneficiary beneficiary-id frz-rows)
                                false true)
                        )
                    )
                    ;;THE SLEEPING LEG IS DERIVED FROM THE STORED TERM, NOT FROM THE LIVE CLOCK,
                    ;;and that is the difference between a sweep that converges and one that
                    ;;quietly breaks every sleeping position it touches. A sleeping multiplier is
                    ;;fixed when the lock is STAKED, from the time it had left at that moment, and
                    ;;`SCR|T|SleepStake` records that term so the unstake gives back exactly what
                    ;;the stake credited. If the target re-derived the leg from TODAY's remaining
                    ;;time the sweep would move the base away from the figure the unstake will
                    ;;reverse -- and once the position is gone that difference is unrecoverable.
                    ;;
                    ;;EXACT ONLY WHILE THE SCORE'S CEILING HOLDS STILL, and that is not an
                    ;;assumption, it is an enforced pairing: `SCR|C>UPDATE-MULTIPLIERS` refuses a
                    ;;change while any sleeping position exists. The two halves are one mechanism
                    ;;-- the ledger stores a ceiling-independent TERM so one row can serve every
                    ;;score on the pool, and the gate is what stops the ceiling moving underneath
                    ;;it. Relaxing that gate without ALSO re-rating the stored legs would make the
                    ;;unstake reverse at a rate the stake never credited.
                    ;;
                    ;;So the sweep repairs the NATIVE and FROZEN legs (whose multipliers are
                    ;;constant, so recomputation is exact) and the add-score backfill, and leaves
                    ;;sleeping weights where their owners earned them.
                    ;;
                    ;;CLASS 0 ONLY, still: a class-1 pool admits DPTF legs and nothing else
                    ;;(URC_StakeTrueFungibleDptfMatchesPool), so its tracker can never hold a
                    ;;sleeping row even when the asset declares a twin.
                    (if (or (= (at "sleeping" legs) BAR)
                            (!= (ref-SCR::UR_SCR|ScoreClass score-id) 0))
                        0.0
                        (ref-SCR::URC_SCR|SleepingLegHeldWeight
                            score-id (at "sleeping" legs)
                            (map (lambda (r:object) (at "nonce" r)) slp-mine)
                            (map (lambda (r:object) (at "balance" r)) slp-mine)
                            300
                        )
                    )
                ]
            )
        )
    )
    (defun URH_AQP|ScoreBackfillLegRows:object (pool-id:string)
        @doc "HEAVY (up to three tracker scans). The pool's whole live liquidity position, by leg: \
            \ {nat-rows, frz-rows, slp-rows}. Scanned ONCE and threaded through every holder."
        (let
            (
                (legs:object (URC_AQP|PoolLiquidityLegs pool-id))
            )
            {"nat-rows" : (URH_AQP|ActiveDptfTrackerRows pool-id (at "native" legs))
            ,"frz-rows" : (if (= (at "frozen" legs) BAR)
                            []
                            (URH_AQP|ActiveDptfTrackerRows pool-id (at "frozen" legs)))
            ,"slp-rows" : (if (= (at "sleeping" legs) BAR)
                            []
                            (URH_AQP|ActiveDpofTrackerRows pool-id (at "sleeping" legs)))}
        )
    )
    (defun URHC_AQP|ScoreBackfillCandidates:[string] (pool-id:string score-id:string leg-rows:object)
        @doc "HEAVY. Every account the sweep must consider: the UNION of the pool tracker's \
            \ beneficiaries and `SCR::URH_SCR|ScoreHolderAccounts`. \
            \ \
            \ THE UNION IS NOT REDUNDANT, and taking only the first half is the bug that makes a \
            \ back-fill look complete while leaving the worst rows behind. The tracker answers 'who \
            \ holds a position', the score table answers 'who carries a base'. The two disagree in \
            \ both directions, and each direction is a real repair: \
            \ \
            \   TRACKER ONLY -> a holder who staked before the score existed (target > 0, base 0). \
            \   SCORE ONLY   -> an ORPHAN: base non-zero with no position left (target 0). This is \
            \                   what `C_AddScore`'s unguarded signed delta produces, and it was \
            \                   measured BELOW ZERO on the deployed chain. Nothing else enumerates \
            \                   it, so no other sweep in the system can reach it."
        (fold
            (lambda (acc:[string] a:string) (if (contains a acc) acc (+ acc [a])))
            (UC_AQP|BackfillUniqueBeneficiaries
                (+ (+ (at "nat-rows" leg-rows) (at "frz-rows" leg-rows)) (at "slp-rows" leg-rows))
            )
            (let
                (
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                )
                (ref-SCR::URH_SCR|ScoreHolderAccounts pool-id score-id)
            )
        )
    )
    (defun URHC_AQP|ScoreBackfillOutstanding:[object] (pool-id:string score-id:string)
        @doc "HEAVY. The sweep's WORK LIST and its 'is it needed?' answer in one read: every holder \
            \ whose stored base disagrees with the canonical target, as \
            \ {beneficiary-id, target, current, delta}, delta != 0. \
            \ \
            \ EMPTY MEANS FULLY RATED -- every slice would be a no-op. That is the signal a UI shows \
            \ an admin as 'score stale', and the condition a pool can clear itself on. \
            \ \
            \ ALSO EMPTY for a score this engine does not support (`URC_AQP|ScoreBackfillSupported`). \
            \ Zero rows, never a wrong count: an unsupported score's base is not Σ(amount × mx), so \
            \ a 'delta' measured against that formula would be invented work that CORRUPTS the row \
            \ if executed. Refusing to answer is the only safe answer."
        (if (not (URC_AQP|ScoreBackfillSupported pool-id score-id))
            []
            (let
                (
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (leg-rows:object (URH_AQP|ScoreBackfillLegRows pool-id))
                )
                (filter
                    (lambda (row:object) (!= (at "delta" row) 0.0))
                    (map
                        (lambda (b:string)
                            (let
                                (
                                    (target:decimal
                                        (URH_AQP|ScoreTargetBaseForBeneficiary
                                            pool-id score-id b
                                            (at "nat-rows" leg-rows)
                                            (at "frz-rows" leg-rows)
                                            (at "slp-rows" leg-rows)))
                                    (current:decimal
                                        (ref-SCR::UR_U-SCR|UserScoreBaseScore b pool-id score-id))
                                )
                                {"beneficiary-id" : b
                                ,"target"         : target
                                ,"current"        : current
                                ,"delta"          : (- target current)}
                            )
                        )
                        (URHC_AQP|ScoreBackfillCandidates pool-id score-id leg-rows)
                    )
                )
            )
        )
    )
    (defun URHC_AQP|ScoreBackfillNeeded:bool (pool-id:string score-id:string)
        @doc "HEAVY. True when a re-rate sweep has work left on (pool-id, score-id). The cheap \
            \ question a client asks before paying for a slice, and the one a pool clears on."
        (> (length (URHC_AQP|ScoreBackfillOutstanding pool-id score-id)) 0)
    )
    (defun URC_AQP|PoolHasWeightedStakers:bool (pool-id:string)
        @doc "CHEAP (at most seven point reads). True when some employed score of this pool already \
            \ carries weight -- which is the only thing that makes adding or revoking a score an \
            \ expensive operation rather than a free one. \
            \ \
            \ WHY NOT THE TRACKER, WHICH IS THE OBVIOUS PLACE TO ASK: answering from the tracker \
            \ costs a `select` per asset leg, and this is consulted on the ADD-SCORE path, which \
            \ every pool owner walks. `nzs-count` is already maintained on each score by the stake \
            \ writer, so the question 'has anybody got weight here' is a handful of point reads. \
            \ \
            \ WHY NOT `nns`, WHICH SOUNDS EXACTLY RIGHT: `nns` is the nonce-occupancy counter and \
            \ it is **-1 on class 0 and class 1 pools** by construction (they are AMOUNT pools --\
            \ see UR_AQP|PoolNns). On the live LP pools it would therefore answer -1 forever, and \
            \ a gate built on it would never fire where it matters most. \
            \ \
            \ ONE BLIND SPOT, STATED: a holder whose weight is exactly 0 is not counted, so a pool \
            \ staked ONLY by additive satellites (whose base is pinned at 0.0 by design) reads \
            \ false. That shape cannot occur -- a satellite boosts off a hub's base, so the hub is \
            \ employed by the same pool and carries the weight that makes this true."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
            )
            (> (length
                   (filter
                       (lambda (sid:string) (> (ref-SCR::UR_SCR|ScoreNzsCount sid) 0))
                       (URC_PoolActiveScoreIds pool-id)))
               0)
        )
    )
    (defun URHC_AQP|PoolOrphanedScores:[string] (pool-id:string)
        @doc "HEAVY (one select over the user-score table). The scores this pool has STOPPED \
            \ employing but whose holders still carry weight for them: \
            \ \
            \     orphans = (scores with holders in this pool) - (scores the pool employs) \
            \ \
            \ EVERY ENTRY IS A DRAIN SWEEP WAITING TO RUN, and an empty list is the pool saying it \
            \ has no retired weight left anywhere. `C_RevokeScore` cannot do this work itself: the \
            \ number of holders is unbounded, so retiring them is a paged, parallel job and not one \
            \ transaction's writes."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (employed:[string] (URC_PoolActiveScoreIds pool-id))
            )
            (filter
                (lambda (sid:string) (not (contains sid employed)))
                (ref-SCR::URH_SCR|PoolScoreIdsWithHolders pool-id)
            )
        )
    )
    (defun URHC_AQP|ScoreDrainOutstanding:[string] (pool-id:string score-id:string)
        @doc "HEAVY. The accounts still carrying weight for a score this pool no longer employs -- \
            \ the drain sweep's work list, and its completion record when it reads []. \
            \ \
            \ EMPTY FOR A SCORE THE POOL STILL EMPLOYS, never a wrong list: a live score is \
            \ re-rated, not drained, and reporting its holders here would invite a caller to zero \
            \ weight that is genuinely earned. The mirror of `URHC_AQP|ScoreBackfillOutstanding`, \
            \ which is empty for exactly the scores this one answers for."
        (if (contains score-id (URC_PoolActiveScoreIds pool-id))
            []
            (let
                (
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                )
                (ref-SCR::URH_SCR|ScoreHolderAccounts pool-id score-id)
            )
        )
    )
    (defun URHC_AQP|PoolSweepClear:bool (pool-id:string)
        @doc "HEAVY. True when this pool has NO outstanding re-rate and NO outstanding drain on any \
            \ score -- the condition under which `sweep-in-progress` may be released and the pool \
            \ returned to trading. \
            \ \
            \ THE WHOLE GATE IN ONE READ, and it is deliberately the SAME read the clearing client \
            \ enforces. A pool is unfrozen because the work is provably done, never because \
            \ somebody asserted it was: a client that trusted a caller's 'finished' flag would \
            \ unfreeze a half-swept pool, and the half left behind is weight nobody can see is \
            \ wrong."
        (and
            (= (length
                   (filter
                       (lambda (sid:string) (URHC_AQP|ScoreBackfillNeeded pool-id sid))
                       (URC_PoolActiveScoreIds pool-id)))
               0)
            (= (length (URHC_AQP|PoolOrphanedScores pool-id)) 0)
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
    (defun URH_AQP|DptfStakesByOwner:[object] (owner-id:string)
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
    (defun URH_AQP|DptfStakesByBeneficiary:[object] (beneficiary-id:string)
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
    (defun URH_AQP|DpofStakesByOwner:[object] (owner-id:string)
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
    (defun URH_AQP|DpofStakesByBeneficiary:[object] (beneficiary-id:string)
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
    (defun URH_AQP|DpsfStakesByOwner:[object] (owner-id:string)
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
    (defun URH_AQP|DpsfStakesByBeneficiary:[object] (beneficiary-id:string)
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
    (defun URH_AQP|DpnfStakesByOwner:[object] (owner-id:string)
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
    (defun URH_AQP|DpnfStakesByBeneficiary:[object] (beneficiary-id:string)
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
    ;; [URCi]   cost readers — single source for exec billing + INFO preview (config/sync)
    (defun URCi_Issue:object{IgnisCollectorV3.OutputCumulator} (output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|C_Issue" "issue-pool")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_IssueStoa:decimal ()
        @doc "STOA cost for pool-issue: the deterrence expressed in DOLLARS, converted at the live \
            \ STOA price by UC_StoaPrice (issue-pool = $10 => 100 STOA). Previously read the raw \
            \ 'smart' usage price (0.02), a pre-rehaul STOA amount that was never \
            \ dollar-denominated and so ignored the peg entirely."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UC_StoaPrice "issue-pool")
        ))
    (defun URCi_AddScore:object{IgnisCollectorV3.OutputCumulator} (output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|C_AddScore" "add-score")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_RevokeScore:object{IgnisCollectorV3.OutputCumulator} (output:[string])
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|C_RevokeScore" "revoke-score")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SetPoolStake:object{IgnisCollectorV3.OutputCumulator} (output:[string])
        @doc "Shared by Enable / Disable pool-stake — one component key is exact because \
            \ AQP-POOL|C_EnablePoolStake and C_DisablePoolStake are both 6.0."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|C_EnablePoolStake" "pool-stake-toggle")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SyncTrueFungibleAnchors:object{IgnisCollectorV3.OutputCumulator} (output:[string])
        @doc "Gas leg for the TF anchor sync; exec concats it with the anchor-repair + meta \
            \ legs (state-dependent)."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|C_SyncTrueFungibleAnchors" "sync-anchors")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_UpdateScoreMultipliers:object{IgnisCollectorV3.OutputCumulator} (output:[string])
        @doc "Cost of re-setting a score's frozen/sleeping multipliers — a settings write, priced \
            \ alongside the other one-shot score settings."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|CC_UpdateScoreMultipliers" "setup")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_BackfillScoreSlice:object{IgnisCollectorV3.OutputCumulator}
        (beneficiaries:[string] output:[string])
        @doc "Gas leg for one re-rate slice. PRICED PER HOLDER, because that is what the \
            \ transaction actually does — one target recomputation and one delta write each. A flat \
            \ price would make a 1-account slice as expensive as a 40-account one and push callers \
            \ toward the single shape the recipe exists to avoid."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (* (dec (length beneficiaries))
                   (r::UC_IgnisPrice "AQP-POOL|CCp_BackfillScoreSlice" "backfill"))
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_BeginScoreRevoke:object{IgnisCollectorV3.OutputCumulator} (output:[string])
        @doc "Cost of vacating a score's pool slot to begin a revoke — a config write, priced with \
            \ the other pool-settings ops."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|C_BeginScoreRevoke" "setup")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_DrainScoreSlice:object{IgnisCollectorV3.OutputCumulator}
        (accounts:[string] output:[string])
        @doc "Gas leg for one drain slice. PRICED PER HOLDER, like the re-rate slice and for the \
            \ same reason: the transaction does one read and one delta write per account, so a flat \
            \ price would make a one-account slice cost what a forty-account slice costs and push \
            \ callers toward the shape the recipe exists to avoid."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (* (dec (length accounts))
                   (r::UC_IgnisPrice "AQP-POOL|Cp_DrainScoreSlice" "backfill"))
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_FinalizeScoreRevoke:object{IgnisCollectorV3.OutputCumulator} (output:[string])
        @doc "Cost of cutting the aqpool-link once a drain is complete — a config write."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|CC_FinalizeScoreRevoke" "setup")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SyncCollectableAnchors:object{IgnisCollectorV3.OutputCumulator} (output:[string])
        @doc "Gas leg for the SF+NF anchor sync; exec concats it with the anchor-repair + \
            \ meta legs (state-dependent). One component key is exact because \
            \ AQP-POOL|C_SyncSemiFungibleAnchors and C_SyncNonFungibleAnchors are both 36.0."
        (let
            (
                (r:module{IgnisCollectorV3} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator
                (r::UC_IgnisPrice "AQP-POOL|C_SyncSemiFungibleAnchors" "sync-anchors")
                AQP|SC_NAME (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_SyncTrueFungibleAnchorsFull:decimal (beneficiary-id:string dptf-id:string)
        @doc "FULL reconstructed IGNIS ifp of C_SyncTrueFungibleAnchors: the read-only mirror of the exec's \
            \ UDC_ConcatenateOutputCumulators [ico-ank ico-meta ico-gas]. ico-ank = ANK anchor-refresh (ignis|small \
            \ x n-live, n-live = live TF anchors on dptf-id) reproducing XE_UpdateTrueFungibleUserAnchorValues; \
            \ ico-meta = the biggest-tier sync-count stamp (XB_SetBenDptfAnkSyncCount); ico-gas = URCi_SyncTrueFungibleAnchors."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (n-live:integer (length (ref-ANK::UR_ANK|AnchorsForAsset dptf-id)))
            )
            (fold (+) 0.0
                [ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                                     ;; ico-ank
                      (ref-IGNIS::UDC_ConstructOutputCumulator
                          (ref-ANK::URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                          AQP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                                     ;; ico-meta
                      (ref-IGNIS::UDC_LegCumulator "ank-sync-count-tf" AQP|SC_NAME))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                                     ;; ico-gas
                      (URCi_SyncTrueFungibleAnchors [beneficiary-id dptf-id]))
                ])
        ))
    (defun URCi_SyncCollectableAnchorsFull:decimal (beneficiary-id:string collectable-id:string)
        @doc "FULL reconstructed IGNIS ifp of C_SyncCollectableAnchors (SF son=true / NF son=false — cost is \
            \ son-independent). Read-only mirror of the exec's UDC_ConcatenateOutputCumulators [ico-ank ico-meta ico-gas]. \
            \ ico-ank = ANK anchor-refresh (ignis|small x n-live, n-live = live anchors on collectable-id) reproducing \
            \ XE_Resync{Semi,Non}FungibleUserAnchorValues (both use URC_TrueFungibleStakeAnchorRefreshIgnis); ico-meta = \
            \ the biggest-tier sync-count stamp (XB_SetBenCollectableAnkSyncCount); ico-gas = URCi_SyncCollectableAnchors."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (n-live:integer (length (ref-ANK::UR_ANK|AnchorsForAsset collectable-id)))
            )
            (fold (+) 0.0
                [ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                                     ;; ico-ank
                      (ref-IGNIS::UDC_ConstructOutputCumulator
                          (ref-ANK::URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                          AQP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) []))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                                     ;; ico-meta
                      (ref-IGNIS::UDC_LegCumulator "ank-sync-count-tf" AQP|SC_NAME))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                                     ;; ico-gas
                      (URCi_SyncCollectableAnchors [beneficiary-id collectable-id]))
                ])
        ))
    ;;{5.4}  Validate [UEV/CAP]
    ;; [UEV] enforce
    (defun UEV_ScoreDefinitionTargetMatchesPool (score-id:string asset-id:string)
        @doc "Refuses a weight definition written against a collection the score's EMPLOYING POOL \
            \ does not stake. No-op while the score is employed by no pool. \
            \ \
            \ WHY (2026-10-06). A score carries no asset-id -- identity resolves Score -> \
            \ aqpool-link -> Pool -> asset-id -- and the definition write validates the collection \
            \ for EXISTENCE only. Pair that with `undefined nonce => 0` rather than a failure and a \
            \ mistyped collection id writes a full set of structurally valid rows that are NEVER \
            \ read: green transaction, dead weights, no signal anywhere. \
            \ \
            \ TWO POINT READS, NO SCAN, DELIBERATELY. The complete check -- enumerate every asset \
            \ this score has definitions for and reject any that is not the pool's -- needs a \
            \ URH_ table scan, which would make every caller in its tree HEAVY (CC_/AA_ doubling) \
            \ and drag a rename through Talos for a guard that runs on a cold path. This asks the \
            \ cheap half of the question and gets the case that actually bites: writing weights \
            \ for the wrong collection on a score that is already employed, i.e. one that may \
            \ already have stakers. \
            \ \
            \ WHAT IT DOES NOT CATCH, stated so nobody reads more into it: definitions written \
            \ BEFORE the score is employed (aqpool-link is BAR, so there is nothing to compare \
            \ against -- the UI flags these as unverified), and an NF trait-key no staked nonce \
            \ carries, which no id comparison can detect."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                ;;
                (aqpool:string (ref-SCR::UR_SCR|ScoreAqpoolLink score-id))
            )
            (enforce
                (or (= aqpool BAR) (= asset-id (UR_AQP|PoolAssetId aqpool)))
                (format
                    "Score {} is employed by pool {}, which stakes {} -- a definition for {} would score nothing"
                    [score-id aqpool (if (= aqpool BAR) BAR (UR_AQP|PoolAssetId aqpool)) asset-id]
                )
            )
        )
    )
    (defun UEV_IssuePoolClassAndAsset (aqp-class:integer asset-id:string)
        @doc "aqp-class 0..4 and asset-id existence / shape for that class (native id only at issue)."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-DPDC:module{DpdcV2} DPDC)
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
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-SWP:module{SwapperV4} SWP)
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
            ;;PRODUCED-TRIAGED (_eagerlet --produced, 2026-09-16): this message claims EXISTENCE, and a
            ;;hard read of the same subject raises before it can say so. Not actionable in isolation --
            ;;it is one of SEVEN AQP guards sharing one root cause and one blocker: the readers are
            ;;shared with the INFO_ previews, and `Stage_02/[6.5]_AQP-INFO.repl` is DELIBERATELY
            ;;fixture-free (it passes "SCR-x"/"DPNF-x" to all 83 AQP readers because AQP prices are
            ;;argument-independent) and PINS those aborts. Defaulting a shared reader turns a pinned
            ;;expect-failure red. Full reasoning at 02_SCORE.pact's SCR|XI>X_ISSUE-NF-SCORE-DEFINITION
            ;;and DEFECT-LEDGER G-37..G-41 + 7.2b; 7.3 records the same blocker for RT-K-007's preview half.
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
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
    (defun UEV_AQP|ScoreMxChangeSafe (score-id:string)
        @doc "HEAVY. Refuses a multiplier change while any frozen or sleeping position exists on the score -- the condition under which nothing can yet be mis-rated. \
            \ \
            \ THE SCAN IS BOUND BEFORE THE `enforce`, AND IT HAS TO BE. Pact evaluates an \
            \ `enforce` CONDITION in read-only/sys-only mode, where a table scan is refused \
            \ outright -- `select` there aborts the transaction with \"Operation disallowed in \
            \ read-only or sys-only mode\". Binding the result in a `let` first moves the scan \
            \ out of that mode, which is exactly what the tree already does for \
            \ `URC_PoolStakeAdmissionOk` (`(enforce stake-admission-ok ...)`). \
            \ \
            \ MEASURED, AND THE OBVIOUS DIAGNOSIS WAS WRONG. The first reading of the abort was \
            \ \"a defcap cannot run a select\", so these checks were moved out of their \
            \ capabilities -- and failed in exactly the same way from a function body, because \
            \ the capability was never the problem. A bound scan works fine inside a defcap. \
            \ What cannot work, anywhere, is a scan as the argument to `enforce`. \
            \ \
            \ It stayed hidden because the only fixture that reached the multiplier gate used a \
            \ score whose pool link was BAR, which short-circuits before the scan. Every score \
            \ actually linked to a pool would have aborted on chain."
        (let
            (
                (safe:bool (URC_AQP|ScoreMxChangeSafe score-id))
            )
            (enforce
                safe
                "A frozen or sleeping position exists for this score -- re-rate it first"
            )
        )
    )
    (defun UEV_AQP|ScoreDrainComplete (pool-id:string score-id:string)
        @doc "HEAVY. Refuses to cut a score's aqpool-link while any holder still carries weight for it -- the last moment at which the remaining work is discoverable, since the link is what tells the orphan scan which pool those rows belong to. \
            \ \
            \ THE SCAN IS BOUND BEFORE THE `enforce`, AND IT HAS TO BE. Pact evaluates an \
            \ `enforce` CONDITION in read-only/sys-only mode, where a table scan is refused \
            \ outright -- `select` there aborts the transaction with \"Operation disallowed in \
            \ read-only or sys-only mode\". Binding the result in a `let` first moves the scan \
            \ out of that mode, which is exactly what the tree already does for \
            \ `URC_PoolStakeAdmissionOk` (`(enforce stake-admission-ok ...)`). \
            \ \
            \ MEASURED, AND THE OBVIOUS DIAGNOSIS WAS WRONG. The first reading of the abort was \
            \ \"a defcap cannot run a select\", so these checks were moved out of their \
            \ capabilities -- and failed in exactly the same way from a function body, because \
            \ the capability was never the problem. A bound scan works fine inside a defcap. \
            \ What cannot work, anywhere, is a scan as the argument to `enforce`. \
            \ \
            \ It stayed hidden because the only fixture that reached the multiplier gate used a \
            \ score whose pool link was BAR, which short-circuits before the scan. Every score \
            \ actually linked to a pool would have aborted on chain."
        (let
            (
                (remaining:integer (length (URHC_AQP|ScoreDrainOutstanding pool-id score-id)))
            )
            (enforce
                (= remaining 0)
                "Drain is not complete: holders still carry weight for this score"
            )
        )
    )
    (defun UEV_BeginScoreRevoke (pool-id:string score-id:string slot-index:integer)
        @doc "Validates the STRUCTURAL half of a revoke: the slot really holds this score, the \
            \ score links back, it is not wired into an FVT, and no employed peer boosts off it. \
            \ \
            \ EVERYTHING `UEV_RevokeScorePoolAndScore` CHECKS EXCEPT THE ZERO TOTALS, and the \
            \ omission is the entire purpose. That validator refuses a score any holder still \
            \ carries weight for -- correctly, because revoking it would strand that weight in the \
            \ score's totals and its `nzs-count` with nothing left to reverse it. But it also made \
            \ revoke UNREACHABLE on a pool anybody had staked into: there was no legitimate way to \
            \ get the totals to zero, since an admin cannot unstake on a holder's behalf. \
            \ \
            \ So the zero-totals requirement moves from a precondition to a GOAL: this begins the \
            \ revoke by vacating the slot, the drain sweep retires the holders in parallel slices, \
            \ and `CC_FinalizeScoreRevoke` cuts the link once the work is provably done. The totals \
            \ still have to be zero before the link goes -- just later, and reachably."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
            )
            (enforce (!= slot-index -1) "score-id is not assigned to pool")
            (enforce
                (fold (and) true
                    [
                        (contains slot-index (enumerate 0 6))
                        (= (URC_PoolScoreSlotValue pool-id slot-index) score-id)
                        (= (ref-SCR::UR_SCR|ScoreAqpoolLink score-id) pool-id)
                        (= (ref-SCR::UR_SCR|ScoreFvtLink score-id) BAR)
                        (URC_NoEmployedBoostLinkTarget pool-id score-id)
                    ]
                )
                "Invalid score revoke-begin for pool (slot, aqpool-link, fvt-link, or boost-link dependents)"
            )
        )
    )
    (defun UEV_StakeBeneficiaryAccount (beneficiary-id:string)
        @doc "Stake paths: beneficiary must exist and be an activated standard (non-principal) Ouronet account."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists beneficiary-id)
            (ref-DALOS::UEV_EnforceAccountType beneficiary-id false)
        )
    )
    (defun UEV_StakeTrueFungibleDptfLeg (dptf-id:string)
        @doc "Reject R| reserved; validate DPTF id exists via DPTF::UEV_id."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (enforce (not (URC_DptfStakeIsReservedLeg dptf-id)) "Reserved DPTF (R|) cannot be staked")
            (ref-DPTF::UEV_id dptf-id)
        )
    )
    (defun UEV_StakeOrtoFungibleDpofLeg (dpof-id:string)
        @doc "Validate issued DPOF id via DPOF::UEV_id."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
            )
            (ref-DPOF::UEV_id dpof-id)
        )
    )
    (defun UEV_StakeCollectableLeg (collectable-id:string son:bool)
        @doc "Validate issued DPDC collectable id via DPDC::UEV_id."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-DPDC::UEV_id collectable-id son)
        )
    )
    ;;
    (defun UEV_ExecutorIzPoolOwner (executor:string pool-id:string)
        @doc "Enforces that <executor> IS the pool's owner konto -- the SAME value CAP_PoolOwner \
            \ resolves and key-checks, read through the same URC_ so the two can never disagree. \
            \ It does not REPLACE that gate: CAP_PoolOwner proves the signer holds the owner's key, \
            \ this proves the named actor IS that owner. Both are needed, because they are not the \
            \ same question -- a sovereign asset's owner is a SMART account whose key a human holds, \
            \ so the key check passes for an account the caller never names (see 01_ANK, 2026-09-20)."
        (enforce (= executor (URC_AqpOwnerKonto pool-id))
            (format "Executor {} is not the owner of pool {} (owner is {})"
                [executor pool-id (URC_AqpOwnerKonto pool-id)]))
    )
    (defun UEV_ExecutorIzAqpAssetOwner (executor:string aqp-class:integer asset-id:string)
        @doc "Issue-time form of UEV_ExecutorIzPoolOwner: the pool does not exist yet, so the \
            \ authority is derived from the canonical asset for <aqp-class>/<asset-id>, mirroring \
            \ CAP_AqpAssetOwner."
        (enforce (= executor (URC_AqpOwnerKontoFromClassAndAsset aqp-class asset-id))
            (format "Executor {} is not the owner of the canonical asset {} (owner is {})"
                [executor asset-id (URC_AqpOwnerKontoFromClassAndAsset aqp-class asset-id)]))
    )
    (defun CAP_AqpAssetOwner (aqp-class:integer asset-id:string)
        @doc "Issue / pre-pool: tx sender must own the canonical asset for aqp-class and asset-id."
        (let 
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (URC_AqpOwnerKontoFromClassAndAsset aqp-class asset-id))
        )
    )
    (defun CAP_PoolOwner (pool-id:string)
        @doc "Post-issue pool governance: tx sender must own the canonical asset behind pool-id (URC_AqpOwnerKonto)."
        (let 
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (URC_AqpOwnerKonto pool-id))
        )
    )
    (defun CAP_StakeOwner (owner-id:string)
        @doc "Stake / unstake: tx sender must own owner-id (depositor of tokens)."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-id)
        )
    )
    ;;{5.5}  Write [W]
    ;; [W]   write
    ;;
    ;; Twelve blocks — one per deftable (table order). Within each block: WI → WW → WU → WU2+ (only when needed).
    ;; WU lists every schema field: defun when used; comment when [.], select key, or mutates via WW_*.
    ;;
    (defun WI_Pool:string
        (pool-id:string row:object{AcquisitionSchemasV1.AQP|Schema})
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
        (pool-id:string vacate-in-progress:bool)
        @doc "Update vacate-in-progress on AQP|T|Pool."
        (require-capability (SECURE))
        (update AQP|T|Pool pool-id
            {"vacate-in-progress"   : vacate-in-progress}
        )
    )
    (defun WU_Pool|Nns:string
        (pool-id:string delta:integer)
        @doc "#FP1: add <delta> to the pool nns occupancy counter. Defensive no-op on amount pools (nns=-1) — the \
            \ nonce-tracker slot writers only call this for class 2/3/4, on a 0<->occupied position transition."
        (require-capability (SECURE))
        (let
            (
                (cur:integer (at "nns" (read AQP|T|Pool pool-id ["nns"])))
            )
            (if (= cur -1)
                "nns N/A (amount pool)"
                (update AQP|T|Pool pool-id {"nns" : (+ cur delta)})
            )
        )
    )
    (defun WU_User|Unn:string
        (pool-id:string beneficiary-id:string delta:integer)
        @doc "Vacate-v2 §4: add <delta> to the (pool, beneficiary) occupancy counter, in lockstep with the \
            \ pool nns. Defensive no-op on amount pools (pool nns=-1, i.e. LP) — the tracker slot writers call \
            \ this only on a 0<->occupied transition for occupancy-tracked pools (class 1/2/3/4)."
        (require-capability (SECURE))
        (if (= (at "nns" (read AQP|T|Pool pool-id ["nns"])) -1)
            "unn N/A (amount pool)"
            (with-default-read AQP|T|UserOccupancy (UCk_UserOccupancy pool-id beneficiary-id)
                {"unn" : 0} {"unn" := cur}
                (write AQP|T|UserOccupancy (UCk_UserOccupancy pool-id beneficiary-id)
                    (UDC_AQP|UserOccupancy (+ cur delta) pool-id beneficiary-id))
            )
        )
    )
    (defun WU_Pool|Occupancy:string
        (pool-id:string beneficiary-id:string delta:integer)
        @doc "Vacate-v2: advance BOTH occupancy counters in lockstep on a tracker 0<->occupied transition — the \
            \ pool nns (#FP1) and the (pool, beneficiary) unn (§4). Both share the nns=-1 LP guard internally, so \
            \ this is a no-op on amount pools. The single call every tracker slot writer makes on a transition."
        (require-capability (SECURE))
        (WU_Pool|Nns pool-id delta)
        (WU_User|Unn pool-id beneficiary-id delta)
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
    ;; WU_Pool|AqpId — select key; WU not needed.
    ;;
    ;; WI_DPTFTracker — not used: first row touch is WW_DPTFTracker (upsert path).
    (defun WW_DPTFTracker:string
        (pool-id:string dptf-id:string owner-id:string beneficiary-id:string row:object{AcquisitionSchemasV1.AQP|TrueFungibleTracker})
        @doc "Upsert full AQP|T|DPTFTracker row for (pool, dptf, owner, beneficiary)."
        (require-capability (SECURE))
        (write AQP|T|DPTFTracker (UCk_DPTFTracker pool-id dptf-id owner-id beneficiary-id) row)
    )
    ;; WU_DPTFTracker|Balance — not used: mutates via WW_DPTFTracker (full row).
    ;; WU_DPTFTracker|PoolId — select key; WU not needed.
    ;; WU_DPTFTracker|DptfId — select key; WU not needed.
    ;; WU_DPTFTracker|OwnerId — select key; WU not needed.
    ;; WU_DPTFTracker|BeneficiaryId — select key; WU not needed.
    ;;
    ;; WI_DPOFTracker — not used: first row touch is WW_DPOFTracker (upsert path).
    (defun WW_DPOFTracker:string
        (pool-id:string dpof-id:string owner-id:string beneficiary-id:string nonce:integer row:object{AcquisitionSchemasV1.AQP|OrtoFungibleTracker})
        @doc "Upsert full AQP|T|DPOFTracker row for (pool, dpof, owner, beneficiary, nonce)."
        (require-capability (SECURE))
        (write AQP|T|DPOFTracker (UCk_DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce) row)
    )
    ;; WU_DPOFTracker|Balance — not used: mutates via WW_DPOFTracker (full row).
    ;; WU_DPOFTracker|PoolId — select key; WU not needed.
    ;; WU_DPOFTracker|DpofId — select key; WU not needed.
    ;; WU_DPOFTracker|OwnerId — select key; WU not needed.
    ;; WU_DPOFTracker|BeneficiaryId — select key; WU not needed.
    ;; WU_DPOFTracker|Nonce — select key; WU not needed.
    ;;
    ;; WI_DPSFTracker — not used: first row touch is WW_DPSFTracker (upsert path).
    (defun WW_DPSFTracker:string
        (pool-id:string dpsf-id:string owner-id:string beneficiary-id:string nonce:integer row:object{AcquisitionSchemasV1.AQP|SemiFungibleTracker})
        @doc "Upsert full AQP|T|DPSFTracker row for (pool, dpsf, owner, beneficiary, nonce)."
        (require-capability (SECURE))
        (write AQP|T|DPSFTracker (UCk_DPSFTracker pool-id dpsf-id owner-id beneficiary-id nonce) row)
    )
    ;; WU_DPSFTracker|Balance — not used: mutates via WW_DPSFTracker (full row).
    ;; WU_DPSFTracker|PoolId — select key; WU not needed.
    ;; WU_DPSFTracker|DpsfId — select key; WU not needed.
    ;; WU_DPSFTracker|OwnerId — select key; WU not needed.
    ;; WU_DPSFTracker|BeneficiaryId — select key; WU not needed.
    ;; WU_DPSFTracker|Nonce — select key; WU not needed.
    ;;
    ;; WI_DPNFTracker — not used: first row touch is WW_DPNFTracker (upsert path).
    (defun WW_DPNFTracker:string
        (pool-id:string dpnf-id:string owner-id:string beneficiary-id:string nonce:integer row:object{AcquisitionSchemasV1.AQP|NonFungibleTracker})
        @doc "Upsert full AQP|T|DPNFTracker row for (pool, dpnf, owner, beneficiary, nonce)."
        (require-capability (SECURE))
        (write AQP|T|DPNFTracker (UCk_DPNFTracker pool-id dpnf-id owner-id beneficiary-id nonce) row)
    )
    ;; WU_DPNFTracker|Balance — not used: mutates via WW_DPNFTracker (full row).
    ;; WU_DPNFTracker|PoolId — select key; WU not needed.
    ;; WU_DPNFTracker|DpnfId — select key; WU not needed.
    ;; WU_DPNFTracker|OwnerId — select key; WU not needed.
    ;; WU_DPNFTracker|BeneficiaryId — select key; WU not needed.
    ;; WU_DPNFTracker|Nonce — select key; WU not needed.
    ;;
    ;; WI_BenDptfTotal — not used: first row touch is WW_BenDptfTotal (upsert path).
    (defun WW_BenDptfTotal:string
        (beneficiary-id:string dptf-id:string row:object{AcquisitionSchemasV1.AQP|BenDptfTotal})
        @doc "Upsert full AQP|T|BenDptfTotal row for (beneficiary, dptf-id)."
        (require-capability (SECURE))
        (write AQP|T|BenDptfTotal (UCk_BenDptfTotal beneficiary-id dptf-id) row)
    )
    (defun WU_BenDptfTotal|LastAnkSyncCount:string
        (beneficiary-id:string dptf-id:string row:object{AcquisitionSchemasV1.AQP|BenDptfTotal} sync-count:integer)
        @doc "Update last-ank-sync-count on AQP|T|BenDptfTotal; preserve other fields. \
            \ <row> kept for call-site symmetry with collectable meta WU_*; write uses update (not object-+ merge)."
        (require-capability (SECURE))
        (update AQP|T|BenDptfTotal (UCk_BenDptfTotal beneficiary-id dptf-id)
            {"last-ank-sync-count": sync-count}
        )
    )
    ;; WU_BenDptfTotal|TotalBalance — not used: mutates via WW_BenDptfTotal (full row).
    ;; WU_BenDptfTotal|BeneficiaryId — select key; WU not needed.
    ;; WU_BenDptfTotal|DptfId — select key; WU not needed.
    ;;
    ;; WI_BenDpsfNonceTotal — not used: first row touch is WW_BenDpsfNonceTotal (upsert path).
    (defun WW_BenDpsfNonceTotal:string
        (beneficiary-id:string dpsf-id:string nonce:integer row:object{AcquisitionSchemasV1.AQP|BenDpsfNonceTotal})
        @doc "Upsert full AQP|T|BenDpsfNonceTotal row for (beneficiary, dpsf-id, nonce)."
        (require-capability (SECURE))
        (write AQP|T|BenDpsfNonceTotal (UCk_BenDpsfNonceTotal beneficiary-id dpsf-id nonce) row)
    )
    ;; WU_BenDpsfNonceTotal|Amount — not used: mutates via WW_BenDpsfNonceTotal (full row).
    ;; WU_BenDpsfNonceTotal|BeneficiaryId — select key; WU not needed.
    ;; WU_BenDpsfNonceTotal|DpsfId — select key; WU not needed.
    ;; WU_BenDpsfNonceTotal|Nonce — select key; WU not needed.
    ;;
    ;; WI_BenDpnfNonceTotal — not used: first row touch is WW_BenDpnfNonceTotal (upsert path).
    (defun WW_BenDpnfNonceTotal:string
        (beneficiary-id:string dpnf-id:string nonce:integer row:object{AcquisitionSchemasV1.AQP|BenDpnfNonceTotal})
        @doc "Upsert full AQP|T|BenDpnfNonceTotal row for (beneficiary, dpnf-id, nonce)."
        (require-capability (SECURE))
        (write AQP|T|BenDpnfNonceTotal (UCk_BenDpnfNonceTotal beneficiary-id dpnf-id nonce) row)
    )
    ;; WU_BenDpnfNonceTotal|Amount — not used: mutates via WW_BenDpnfNonceTotal (full row).
    ;; WU_BenDpnfNonceTotal|BeneficiaryId — select key; WU not needed.
    ;; WU_BenDpnfNonceTotal|DpnfId — select key; WU not needed.
    ;; WU_BenDpnfNonceTotal|Nonce — select key; WU not needed.
    ;;
    ;; WI_BenDpsfAnkMeta — not used: first row touch is WW_BenDpsfAnkMeta (upsert path).
    (defun WW_BenDpsfAnkMeta:string
        (beneficiary-id:string dpsf-id:string row:object{AcquisitionSchemasV1.AQP|BenDpsfAnkMeta})
        @doc "Upsert full AQP|T|BenDpsfAnkMeta row for (beneficiary, dpsf-id)."
        (require-capability (SECURE))
        (write AQP|T|BenDpsfAnkMeta (UCk_BenDpsfAnkMeta beneficiary-id dpsf-id) row)
    )
    (defun WU_BenDpsfAnkMeta|LastAnkSyncCount:string
        (beneficiary-id:string dpsf-id:string row:object{AcquisitionSchemasV1.AQP|BenDpsfAnkMeta} sync-count:integer)
        @doc "Update last-ank-sync-count; preserve active-nonce-count from <row>."
        (require-capability (SECURE))
        (write AQP|T|BenDpsfAnkMeta (UCk_BenDpsfAnkMeta beneficiary-id dpsf-id)
            (UDC_AQP|BenDpsfAnkMeta sync-count (at "active-nonce-count" row) beneficiary-id dpsf-id)
        )
    )
    ;; WU_BenDpsfAnkMeta|BeneficiaryId — select key; WU not needed.
    ;; WU_BenDpsfAnkMeta|DpsfId — select key; WU not needed.
    ;;
    ;; WI_BenDpnfAnkMeta — not used: first row touch is WW_BenDpnfAnkMeta (upsert path).
    (defun WW_BenDpnfAnkMeta:string
        (beneficiary-id:string dpnf-id:string row:object{AcquisitionSchemasV1.AQP|BenDpnfAnkMeta})
        @doc "Upsert full AQP|T|BenDpnfAnkMeta row for (beneficiary, dpnf-id)."
        (require-capability (SECURE))
        (write AQP|T|BenDpnfAnkMeta (UCk_BenDpnfAnkMeta beneficiary-id dpnf-id) row)
    )
    (defun WU_BenDpnfAnkMeta|LastAnkSyncCount:string
        (beneficiary-id:string dpnf-id:string row:object{AcquisitionSchemasV1.AQP|BenDpnfAnkMeta} sync-count:integer)
        @doc "Update last-ank-sync-count; preserve active-nonce-count from <row>."
        (require-capability (SECURE))
        (write AQP|T|BenDpnfAnkMeta (UCk_BenDpnfAnkMeta beneficiary-id dpnf-id)
            (UDC_AQP|BenDpnfAnkMeta sync-count (at "active-nonce-count" row) beneficiary-id dpnf-id)
        )
    )
    ;;{5.6}  Aux/X
    ;; [XI]
    ;;Protection: Class 1 — Innate protection offered by WI_Pool
    (defun XI_IssuePool:string
        (pool-id:string aqp-class:integer asset-id:string)
        @doc "Insert AQP|T|Pool under SECURE (from AQP|C>ISSUE-POOL). Write only; C_Issue builds IGNIS."
        ;; SECURE: granted by WI_Pool (underlying W_).
        (WI_Pool pool-id (UDC_AQP|Schema aqp-class asset-id pool-id))
        pool-id
    )
    ;;Protection: Class 1 — Innate protection offered by WU_Pool|ScoreSlot
    (defun XI_AddScoreToPool:string
        (pool-id:string score-id:string slot-index:integer)
        @doc "Write score-id into the first free slot (0=primary .. 6=septenary). Under SECURE from AQP|C>ADD-SCORE."
        ;; SECURE: granted by WU_Pool|ScoreSlot (underlying W_).
        (WU_Pool|ScoreSlot pool-id slot-index score-id)
        score-id
    )
    ;;Protection: Class 1 — Innate protection offered by WU7_Pool|ScoreSlots
    (defun XI_RevokeScoreFromPool:string
        (pool-id:string slot-index:integer)
        @doc "Remove score at slot-index and compact higher slots down (0=primary .. 6=septenary). Under SECURE from AQP|C>REVOKE-SCORE."
        ;; SECURE: granted by WU7_Pool|ScoreSlots (underlying W_).
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
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
    ;;Protection: Class 1 — Innate protection offered by WW_DPSFTracker, WU_Pool|Occupancy,
    ;;Protection:          WW_DPNFTracker
    (defun XI_1|WriteCollectableTrackerSlot:object{IgnisCollectorV3.OutputCumulator}
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
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
                    ;; #FP1: pool nns occupancy — +1 when this position goes empty->occupied, -1 on last-amount removal
                    (if (and (= bal 0.0) (> new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id 1)
                        (if (and (> bal 0.0) (= new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id -1) "no nns transition"))
                )
                (let
                    (
                        (bal:decimal (UR_AQP|DPNFTrackerBalance pool-id collectable-id owner-id beneficiary-id nonce))
                        (new-bal:decimal (+ bal delta))
                    )
                    (WW_DPNFTracker pool-id collectable-id owner-id beneficiary-id nonce
                        (UDC_AQP|NonFungibleTracker new-bal pool-id collectable-id owner-id beneficiary-id nonce)
                    )
                    ;; #FP1: pool nns occupancy — +1 when this position goes empty->occupied, -1 on last-amount removal
                    (if (and (= bal 0.0) (> new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id 1)
                        (if (and (> bal 0.0) (= new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id -1) "no nns transition"))
                )
            )
            (ref-IGNIS::UDC_LegCumulator "tracker-write-collectable" AQP|SC_NAME)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XI_2|BumpBenDpsfNonceTotal,
    ;;Protection:          XI_2|BumpBenDpnfNonceTotal
    (defun XI_1|BumpBenCollectableNonceTotalSlot:object{IgnisCollectorV3.OutputCumulator}
        (beneficiary-id:string collectable-id:string son:bool nonce:integer amount:integer direction:bool)
        @doc "One BenDpsfNonceTotal or BenDpnfNonceTotal row — son dispatch to XI_2 leaf."
        ;; SECURE: granted by XI_2|BumpBenDpsfNonceTotal / XI_2|BumpBenDpnfNonceTotal (underlying W_).
        (if son
            (XI_2|BumpBenDpsfNonceTotal beneficiary-id collectable-id nonce amount direction)
            (XI_2|BumpBenDpnfNonceTotal beneficiary-id collectable-id nonce amount direction)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_BenDpsfNonceTotal,
    ;;Protection:          WW_BenDpsfAnkMeta
    (defun XI_2|BumpBenDpsfNonceTotal:object{IgnisCollectorV3.OutputCumulator}
        (beneficiary-id:string dpsf-id:string nonce:integer amount:integer direction:bool)
        @doc "AQP|T|BenDpsfNonceTotal: bump amount ±supply for (beneficiary, dpsf-id, nonce) across pools. \
            \ Also bumps BenDpsfAnkMeta.active-nonce-count when amount crosses 0↔positive."
        ;; SECURE: granted by WW_BenDpsfNonceTotal / WW_BenDpsfAnkMeta (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (amt:integer (UR_AQP|BenDpsfNonceAmount beneficiary-id dpsf-id nonce))
                (delta:integer (if direction amount (- amount)))
                (new-amt:integer (+ amt delta))
                (meta:object{AcquisitionSchemasV1.AQP|BenDpsfAnkMeta} (UR_AQP|BenDpsfAnkMeta beneficiary-id dpsf-id))
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
            (ref-IGNIS::UDC_LegCumulator "ben-nonce-total-sf" AQP|SC_NAME)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_BenDpnfNonceTotal,
    ;;Protection:          WW_BenDpnfAnkMeta
    (defun XI_2|BumpBenDpnfNonceTotal:object{IgnisCollectorV3.OutputCumulator}
        (beneficiary-id:string dpnf-id:string nonce:integer amount:integer direction:bool)
        @doc "AQP|T|BenDpnfNonceTotal: bump amount ±supply for (beneficiary, dpnf-id, nonce) across pools. \
            \ Also bumps BenDpnfAnkMeta.active-nonce-count when amount crosses 0↔positive."
        ;; SECURE: granted by WW_BenDpnfNonceTotal / WW_BenDpnfAnkMeta (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (amt:integer (UR_AQP|BenDpnfNonceAmount beneficiary-id dpnf-id nonce))
                (delta:integer (if direction amount (- amount)))
                (new-amt:integer (+ amt delta))
                (meta:object{AcquisitionSchemasV1.AQP|BenDpnfAnkMeta} (UR_AQP|BenDpnfAnkMeta beneficiary-id dpnf-id))
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
            (ref-IGNIS::UDC_LegCumulator "ben-nonce-total-nf" AQP|SC_NAME)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_DPTFTracker, WU_Pool|Occupancy
    (defun XI_1|WriteDptfTrackerSlot:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "One AQP|T|DPTFTracker row — read balance, write ±amount (cap validates unstake sufficiency)."
        ;; SECURE: granted by WW_DPTFTracker (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (bal:decimal (UR_AQP|DPTFTrackerBalance pool-id dptf-id owner-id beneficiary-id))
                (delta:decimal (if direction amount (- amount)))
                (new-bal:decimal (+ bal delta))
            )
            (WW_DPTFTracker pool-id dptf-id owner-id beneficiary-id
                (UDC_AQP|TrueFungibleTracker new-bal pool-id dptf-id owner-id beneficiary-id)
            )
            ;; #FP1 universal nns: TF leg occupancy — +1 empty->occupied, -1 occupied->empty (last amount out).
            ;; No-op on LP pools (class 0, nns=-1) via the WU_Pool|Nns guard. Covers TF stake AND unstake.
            (if (and (= bal 0.0) (> new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id 1)
                (if (and (> bal 0.0) (= new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id -1) "no nns transition"))
            (ref-IGNIS::UDC_LegCumulator "tracker-write-tf" AQP|SC_NAME)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_DPTFTracker, WU_Pool|Occupancy
    (defun XI_1|ZeroDptfTrackerSlot:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string)
        @doc "Vacate: write AQP|T|DPTFTracker balance=0. #FP1: reads the pre-balance so the pool nns occupancy \
            \ counter can record the occupied->empty transition (the old 'no read' shortcut yields to correct nns)."
        ;; SECURE: granted by WW_DPTFTracker (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (bal:decimal (UR_AQP|DPTFTrackerBalance pool-id dptf-id owner-id beneficiary-id))
            )
            (WW_DPTFTracker pool-id dptf-id owner-id beneficiary-id
                (UDC_AQP|TrueFungibleTracker 0.0 pool-id dptf-id owner-id beneficiary-id)
            )
            ;; #FP1 universal nns: zeroing an OCCUPIED leg is an occupied->empty transition (-1). No-op on LP.
            (if (> bal 0.0) (WU_Pool|Occupancy pool-id beneficiary-id -1) "no nns transition")
            (ref-IGNIS::UDC_LegCumulator "tracker-zero-tf" AQP|SC_NAME)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_BenDptfTotal
    (defun XI_1|BumpBenDptfTotalSlot:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "One AQP|T|BenDptfTotal row — bump total-balance ±amount; preserve last-ank-sync-count."
        ;; SECURE: granted by WW_BenDptfTotal (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (tb:decimal (UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
                (sc:integer (UR_AQP|BenDptfLastAnkSyncCount beneficiary-id dptf-id))
                (delta:decimal (if direction amount (- amount)))
                (new-total:decimal (+ tb delta))
            )
            (WW_BenDptfTotal beneficiary-id dptf-id
                (UDC_AQP|BenDptfTotal new-total sc beneficiary-id dptf-id)
            )
            (ref-IGNIS::UDC_LegCumulator "ben-total-tf" AQP|SC_NAME)
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_DPOFTracker, WU_Pool|Occupancy
    (defun XI_1|WriteDpofTrackerSlot:object{IgnisCollectorV3.OutputCumulator}
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
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (bal:decimal (UR_AQP|DPOFTrackerBalance pool-id dpof-id owner-id beneficiary-id nonce))
                (delta:decimal (if direction amount (- amount)))
                (new-bal:decimal (+ bal delta))
            )
            (WW_DPOFTracker pool-id dpof-id owner-id beneficiary-id nonce
                (UDC_AQP|OrtoFungibleTracker new-bal pool-id dpof-id owner-id beneficiary-id nonce)
            )
            ;; #FP1: pool nns occupancy — OF moves the whole nonce, so every move is a full 0<->occupied transition
            (if (and (= bal 0.0) (> new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id 1)
                (if (and (> bal 0.0) (= new-bal 0.0)) (WU_Pool|Occupancy pool-id beneficiary-id -1) "no nns transition"))
            (ref-IGNIS::UDC_LegCumulator "tracker-write-of" AQP|SC_NAME)
        )
    )
    ;; [XE]
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_SetVacateJobState:string
        (pool-id:string vacate-in-progress:bool)
        @doc "Write vacate-in-progress on AQP|T|Pool. P|UEV_IMC gates AQP-VCT caller."
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            ;; SECURE: granted by WU4_Pool|VacateJobState (underlying W_).
            (WU4_Pool|VacateJobState pool-id vacate-in-progress)
        )
        pool-id
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_SetSweepInProgress:string
        (pool-id:string flag:bool)
        @doc "Forward (re-score sweep · MTX-AQP): freeze/unfreeze a pool for a sweep — blocks new stakes AND collect \
            \ while true (D3). P|UEV_IMC gates the caller; P|SECURE-CALLER composes SECURE."
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            ;; SECURE: granted by WU_Pool|SweepInProgress (underlying W_).
            (WU_Pool|SweepInProgress pool-id flag)
        )
        pool-id
    )
    ;;
    ;; --- Block B · Phase 1 custody (FVT::C_*StakeFlow) ---
    ;;   Phase 1 — move assets user↔vault and record pool-local + cross-pool custody.
    ;;   1.1 Transfer          UrStoa ≡ X_UR|Transfer
    ;;   1.2 Pool tracker      UrStoa ≡ (implicit in vault accounting)
    ;;   1.3 Beneficiary rollup UrStoa ≡ N/A (TF cross-pool O(1) for ANK)
    ;;
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY
    (defun XE_TrueFungibleTransfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Phase 1.1 — UrStoa ≡ X_UR|Transfer. TFT::C_Transfer owner↔AQP|SC_NAME. Composes custody cap (validation once per tx). \
            \ \
            \ PROVISIONAL PATRON SLOT CLEARED, 2026-09-22. The inner transfer carried \
            \ <owner-id> in the patron slot -- registered in _patronslots as provisional -- \
            \ because no caller had a patron to give. 05_FVT's turn gave the stake flows a \
            \ real one, so the payer is now the payer. HANDOFF 4e promises every provisional \
            \ slot is written down AND re-pointed when its turn lands; this is the re-pointing."
        (P|UEV_IMC)
        (with-capability (AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY pool-id owner-id beneficiary-id dptf-id amount direction)
            (let
                (
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;
                    (vault:string AQP|SC_NAME)
                )
                (if direction
                    (ref-TFT::C_Transfer patron owner-id vault dptf-id amount true)
                    (ref-TFT::C_Transfer patron vault owner-id dptf-id amount true)
                )
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_TrueFungiblePoolTracker:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Phase 1.2 — per-pool AQP|T|DPTFTracker row. UrStoa: N/A. P|SECURE-CALLER (no custody re-validation)."
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|WriteDptfTrackerSlot pool-id owner-id beneficiary-id dptf-id amount direction)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_ZeroDptfTrackerSlot:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string)
        @doc "IMC: zero one AQP|T|DPTFTracker row (write-only). Called from AQP-VCT vacate."
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|ZeroDptfTrackerSlot pool-id owner-id beneficiary-id dptf-id)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_TrueFungibleBeneficiaryRollup:object{IgnisCollectorV3.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Phase 1.3 — cross-pool AQP|T|BenDptfTotal. UrStoa ≡ N/A. P|SECURE-CALLER."
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (XI_1|BumpBenDptfTotalSlot pool-id owner-id beneficiary-id dptf-id amount direction)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY
    (defun XE_OrtoFungibleTransfer:object{IgnisCollectorV3.OutputCumulator}
        (patron:string 
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
            nonce-amounts:[decimal]
            direction:bool
        )
        @doc "Phase 1.1 — UrStoa ≡ X_UR|Transfer. DPOF::C_Transfer whole nonces. Composes custody cap (validation once per tx)."
        (P|UEV_IMC)
        (with-capability (AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts direction)
            (let
                (
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    ;;
                    (vault:string AQP|SC_NAME)
                    (sender:string (if direction owner-id vault))
                    (receiver:string (if direction vault owner-id))
                )
                (ref-DPOF::C_Transfer patron sender receiver dpof-id nonces true)
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_OrtoFungiblePoolTracker:object{IgnisCollectorV3.OutputCumulator}
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
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (l:integer (length nonces))
                    (slot-ocs:[object{IgnisCollectorV3.OutputCumulator}]
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
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          AQP|XE>COLLECTABLE-POOL-CUSTODY
    (defun XE_CollectableTransfer:object{IgnisCollectorV3.OutputCumulator}
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Phase 1.1 — UrStoa ≡ X_UR|Transfer. DPDC-T::C_Transfer. Composes custody cap (validation once per tx). \
            \ \
            \ PROVISIONAL PATRON SLOT CLEARED, 2026-09-22. The inner transfer carried \
            \ <owner-id> in the patron slot -- registered in _patronslots as provisional -- \
            \ because no caller had a patron to give. 05_FVT's turn gave the stake flows a \
            \ real one, so the payer is now the payer. HANDOFF 4e promises every provisional \
            \ slot is written down AND re-pointed when its turn lands; this is the re-pointing."
        (P|UEV_IMC)
        (with-capability
            (AQP|XE>COLLECTABLE-POOL-CUSTODY
                pool-id owner-id beneficiary-id collectable-id son nonces nonce-amounts direction
            )
            (let
                (
                    (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                    ;;
                    (vault:string AQP|SC_NAME)
                    (sender:string (if direction owner-id vault))
                    (receiver:string (if direction vault owner-id))
                )
                (ref-DPDC-T::C_Transfer patron sender receiver [collectable-id] [son] [nonces] [nonce-amounts] true)
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_CollectablePoolTracker:object{IgnisCollectorV3.OutputCumulator}
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
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (l:integer (length nonces))
                    (slot-ocs:[object{IgnisCollectorV3.OutputCumulator}]
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
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XE_CollectableBeneficiaryRollup:object{IgnisCollectorV3.OutputCumulator}
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
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (l:integer (length nonces))
                    (slot-ocs:[object{IgnisCollectorV3.OutputCumulator}]
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
    ;; [XB]
    ;;
    ;; Depth: C_* → XI_* (depth 0) ; XE_* / XB_* → XI_1|* (depth 1). Map order = entry first.
    ;;
    ;; --- Block A · C_* pool lifecycle ---
    ;;   C_Issue → XI_IssuePool
    ;;   C_AddScore → XI_AddScoreToPool
    ;;   C_RevokeScore → XI_RevokeScoreFromPool
    ;;   C_DisablePoolStake / C_EnablePoolStake → XB_SetPoolStakeEnabled (also AQP-VCT vacate via IMC)
    ;;
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          P|SECURE-CALLER
    (defun XB_SetPoolStakeEnabled:string
        (pool-id:string enabled:bool)
        @doc "Write stake-enabled on AQP|T|Pool. P|UEV_IMC gates cross-module callers (e.g. AQP-VCT vacate). \
            \ Same-module C_Disable/C_Enable compose owner caps then call here."
        (P|UEV_IMC)
        (with-capability (P|SECURE-CALLER)
            ;; SECURE: granted by WU_Pool|StakeEnabled (underlying W_).
            (WU_Pool|StakeEnabled pool-id enabled)
        )
        pool-id
    )
    ;;
    ;; --- Block C · TF stake phase 2.2 (FVT::XI_RefreshTrueFungibleStakeAnchors backward) ---
    ;;   XB_SetBenDptfAnkSyncCount
    ;;
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC
    (defun XB_SetBenDptfAnkSyncCount:object{IgnisCollectorV3.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
        @doc "Backward (FVT::CC_TrueFungibleStakeFlow phase 2.2]): set last-ank-sync-count on BenDptfTotal \
            \ (:= AQP-ANK::UR_AA|AnchorsActive dptf-id); preserve total-balance. P|UEV_IMC + AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC. \
            \ Same-module C_SyncTrueFungibleAnchors and cross-module FVT::XI_RefreshTrueFungibleStakeAnchors call here."
        (P|UEV_IMC)
        (with-capability (AQP|XE>SET-BENEFICIARY-DPTF-ANK-SYNC beneficiary-id dptf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    ;;
                    (row:object{AcquisitionSchemasV1.AQP|BenDptfTotal} (UR_AQP|BenDptfTotal beneficiary-id dptf-id))
                    (live-count:integer (ref-ANK::UR_AA|AnchorsActive dptf-id))
                )
                ;; SECURE: granted by WU_BenDptfTotal|LastAnkSyncCount (underlying W_).
                (WU_BenDptfTotal|LastAnkSyncCount beneficiary-id dptf-id row live-count)
                (ref-IGNIS::UDC_LegCumulator "ank-sync-count-tf" AQP|SC_NAME)
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          AQP|XE>SET-BEN-COLLECTABLE-ANK-SYNC
    (defun XB_SetBenCollectableAnkSyncCount:object{IgnisCollectorV3.OutputCumulator}
        (beneficiary-id:string collectable-id:string son:bool)
        @doc "Backward (FVT collectable stake phase 3 / C_SyncCollectableAnchors): stamp last-ank-sync-count \
            \ on BenDpsfAnkMeta or BenDpnfAnkMeta. P|UEV_IMC + AQP|XE>SET-BEN-COLLECTABLE-ANK-SYNC."
        (P|UEV_IMC)
        (with-capability (AQP|XE>SET-BEN-COLLECTABLE-ANK-SYNC beneficiary-id collectable-id son)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    ;;
                    (live-count:integer (ref-ANK::UR_AA|AnchorsActive collectable-id))
                )
                (if son
                    (let
                        (
                            (row:object{AcquisitionSchemasV1.AQP|BenDpsfAnkMeta} (UR_AQP|BenDpsfAnkMeta beneficiary-id collectable-id))
                        )
                        ;; SECURE: granted by WU_BenDpsfAnkMeta|LastAnkSyncCount (underlying W_).
                        (WU_BenDpsfAnkMeta|LastAnkSyncCount beneficiary-id collectable-id row live-count)
                    )
                    (let
                        (
                            (row:object{AcquisitionSchemasV1.AQP|BenDpnfAnkMeta} (UR_AQP|BenDpnfAnkMeta beneficiary-id collectable-id))
                        )
                        ;; SECURE: granted by WU_BenDpnfAnkMeta|LastAnkSyncCount (underlying W_).
                        (WU_BenDpnfAnkMeta|LastAnkSyncCount beneficiary-id collectable-id row live-count)
                    )
                )
                (ref-IGNIS::UDC_LegCumulator "ank-sync-count-collectable" AQP|SC_NAME)
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;; [C]   client
    ;;
    ;;Lifecycle (AQP|T|Pool / AQP|Schema)
    (defun C_Issue:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-name:string asset-id:string aqp-class:integer)
        @doc "Create a new pool (canonical native asset-id + aqp-class). Patron pays STOA smart + IGNIS; \
            \ returns pool-id in output list. Score slots start BAR."
        (P|UEV_IMC)
        (with-capability (AQP|C>ISSUE-POOL executor pool-name asset-id aqp-class)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (pool-id:string (ref-U|DALOS::UDC_Makeid pool-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::XE_CollectStoa patron (URCi_IssueStoa))
                (XI_IssuePool pool-id aqp-class asset-id)
                (URCi_Issue [pool-id])
            )
        )
    )
    ;;Score slots (score-primary … score-septenary); score-class must match pool aqp-class.
    (defun C_AddScore:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string score-id:string)
        @doc "Assign score-id to the first free pool slot; SCR XE_CreateAqpoolLink then XI pool slot write. \
            \ URC_FirstFreeScoreSlotIndex runs once before the cap; slot-index is passed through. \
            \ IGNIS only (GAS|ADD-SCORE 500.0 on AQP|SC_NAME); no STOA."
        (P|UEV_IMC)
        (let 
            (
                (slot-index:integer (URC_FirstFreeScoreSlotIndex pool-id))
            )
            (with-capability (AQP|C>ADD-SCORE executor pool-id score-id slot-index)
                (let
                    (
                        (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        ;;
                        (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    )
                    (ref-SCR::XE_CreateAqpoolLink score-id pool-id)
                    (XI_AddScoreToPool pool-id score-id slot-index)
                    ;;FREEZE A POOL THAT ALREADY HAS WEIGHT. Every existing staker's base for the
                    ;;new score is 0 while their canonical target is not, so from this instant the
                    ;;pool is mis-scored until the re-rate sweep runs. Leaving it tradeable would
                    ;;let stakes and claims land against weights the chain already knows are
                    ;;wrong, and an UNSTAKE would reverse a figure the chain has already decided
                    ;;is wrong -- irrecoverably, because the position is then gone.
                    ;;Checked AFTER the slot write, which is harmless: the score just added has
                    ;;`nzs-count` 0 and so cannot be what makes the staker test true.
                    ;;
                    ;;FREEZE ONLY IF A SWEEP COULD ACTUALLY CLEAR IT, which is the second
                    ;;conjunct and is not optional. The re-rate engine supports class-0 LP scores
                    ;;only -- an SF/NF score's base is per-nonce TABLE VALUES, not amount x mx --
                    ;;so on any other pool shape there is no sweep that can make progress and a
                    ;;freeze would be a pool nobody could ever unfreeze by doing the work.
                    ;;Measured, not theorised: `CustodiansPool` is aqp-class 3, and
                    ;;`CC_Step14_OpenCustodiansAgency` employs an agency's triplet in it and
                    ;;stakes IN THE SAME TRANSACTION. Freezing on the staker test alone broke
                    ;;that flow at the second agency, for a sweep that would have had nothing to
                    ;;do. Both conjuncts are CHEAP -- point reads and the slot list, no select --
                    ;;which is why this stays a `C_` and not a `CC_`.
                    (if (and (URC_AQP|PoolHasWeightedStakers pool-id)
                             (URC_AQP|ScoreBackfillSupported pool-id score-id))
                        (WU_Pool|SweepInProgress pool-id true)
                        "No re-ratable drift: either the pool carries no weight yet, or this score shape has no sweep")
                    (URCi_AddScore [pool-id score-id])
                )
            )
        )
    )
    (defun C_RevokeScore:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string score-id:string)
        @doc "Clear score-id from its pool slot (compact higher slots); SCR XE_RevokeAqpoolLink then XI pool slot write. \
            \ URC_ScoreSlotIndexForScore runs once before the cap; slot-index is passed through. \
            \ IGNIS only (GAS|REVOKE-SCORE 500.0 on AQP|SC_NAME); no STOA."
        (P|UEV_IMC)
        (let
            (
                (slot-index:integer (URC_ScoreSlotIndexForScore pool-id score-id))
            )
            (with-capability (AQP|C>REVOKE-SCORE executor pool-id score-id slot-index)
                (let
                    (
                        (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        ;;
                        (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    )
                    (ref-SCR::XE_RevokeAqpoolLink score-id pool-id)
                    (XI_RevokeScoreFromPool pool-id slot-index)
                    (URCi_RevokeScore [pool-id score-id])
                )
            )
        )
    )
    (defun C_DisablePoolStake:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string)
        @doc "Pool owner pauses new stakes (stake-enabled → false). IGNIS only (GAS|SET-POOL-STAKE); no STOA."
        (P|UEV_IMC)
        (with-capability (AQP|C>DISABLE-POOL-STAKE executor pool-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (XB_SetPoolStakeEnabled pool-id false)
                (URCi_SetPoolStake [pool-id])
            )
        )
    )
    (defun C_EnablePoolStake:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string)
        @doc "Pool owner re-enables new stakes (stake-enabled → true). IGNIS only (GAS|SET-POOL-STAKE); no STOA."
        (P|UEV_IMC)
        (with-capability (AQP|C>ENABLE-POOL-STAKE executor pool-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (XB_SetPoolStakeEnabled pool-id true)
                (URCi_SetPoolStake [pool-id])
            )
        )
    )
    (defun CC_UpdateScoreMultipliers:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string score-id:string
         mx-frozen:decimal mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Re-set a score's frozen, sleeping and hibernating multipliers. Score owner only. \
            \ \
            \ LIVES HERE RATHER THAN IN AQP-SCORE FOR ONE REASON: the safety condition is about \
            \ POOL POSITIONS, and AQP-SCORE deploys first — it cannot read this module's tracker. \
            \ AQP-POOL can see both, so the gate is enforced here and the write is delegated to \
            \ `SCR::XE_SetScoreMultipliers`, which enforces what IT can prove: ownership, fee \
            \ validity, and `mx-frozen >= 2*mx-sleeping - 1`. \
            \ \
            \ WHY `mx-sleeping` IS NOW A CEILING AND NOT A FACTOR. A sleeping lock earns \
            \ `1 + (months/300) x (mx-sleeping - 1)`, reaching the ceiling only at the full \
            \ 25-year term the chain itself refuses to exceed. Before this, one day of sleep and \
            \ twenty-five years earned the identical multiplier, which is free money for whoever \
            \ noticed. `mx-frozen` stays FLAT because a freeze is irreversible — there is no \
            \ unfreeze in the tree — so it is already the maximum commitment and has nothing to \
            \ scale against. \
            \ \
            \ REFUSED WHILE A FROZEN OR SLEEPING POSITION EXISTS, and this gate is TEMPORARY. The \
            \ owner's standing decision is that a change re-rates every affected stake through a \
            \ parallel sweep; that sweep is not in this round, so until it lands a change is \
            \ allowed only where it provably cannot corrupt anything. Native stakes multiply by \
            \ 1.0 and never read `mx`, so native holders — the only kind on chain today — neither \
            \ block the change nor are touched by it. \
            \ EXECUTOR: BOUND IN `AQP|C>UPDATE-SCORE-MULTIPLIERS`, which enforces \
            \ `executor == UR_SCR|ScoreOwnerKonto(score-id)`, and PROVEN by the callee's \
            \ `SCR|C>UPDATE-MULTIPLIERS` reaching `CAP_EnforceAccountOwnership` on that same \
            \ owner. Named here because the canon requires the route to be stated, not inferred. \
            \ (patron/executor canon 2.2.)"
        (P|UEV_IMC)
        (UEV_AQP|ScoreMxChangeSafe score-id)
        (with-capability
            (AQP|C>UPDATE-SCORE-MULTIPLIERS patron executor score-id mx-frozen mx-sleeping mx-hibernated)
            (let
                (
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                )
                (ref-SCR::XE_SetScoreMultipliers score-id mx-frozen mx-sleeping mx-hibernated)
            )
        )
        ;;THE MESSAGE NAMES WHICH ONES SCALE AND WHICH DO NOT, because the three numbers do not
        ;;mean the same kind of thing and a caller reading back "2.0 / 2.0 / 2.0" would reasonably
        ;;assume they do. Frozen is flat because a freeze is irreversible and already the maximum
        ;;commitment; sleeping is a CEILING reached only at the full 300-month term; hibernating is
        ;;flat because it asks no commitment at all.
        (URCi_UpdateScoreMultipliers
            [(format "Score {} multipliers set: frozen {} (flat) / sleeping UP TO {} (ceiling at 300 months) / hibernating {} (flat)"
                [score-id mx-frozen mx-sleeping mx-hibernated])])
    )
    (defun CCp_BackfillScoreSlice:object{IgnisCollectorV3.OutputCumulator}
        (patron:string pool-id:string score-id:string beneficiaries:[string])
        @doc "HYDRA FED SLICE — re-rate exactly the listed holders of <score-id> to their canonical \
            \ base. Run one per slice of `URHC_AQP|ScoreBackfillOutstanding`; slices are \
            \ order-independent and may be sent in parallel. \
            \ \
            \ FED SLICE, NOT A CURSOR PAGER, and the distinction is the whole reason this is safe to \
            \ fan out: the caller passes the explicit account list, so nothing is read from stored \
            \ progress and two transactions cannot race over a shared cursor. A pager — which \
            \ computes its own window — would have to be sent strictly sequentially. \
            \ \
            \ TARGET RECOMPUTED IMMEDIATELY BEFORE EACH WRITE, inside the map, never batched ahead \
            \ of them. That one ordering choice is what makes the recipe idempotent, repeat-safe and \
            \ order-independent at once: whatever earlier slices did is already visible, so an \
            \ account that no longer needs work contributes a delta of exactly 0.0. Batching the \
            \ deltas first would reintroduce every one of those hazards while looking tidier. \
            \ \
            \ THE DELTA GOES THROUGH THE STAKE PATH'S OWN WRITER (`SCR::XE_ApplyRawBaseDelta` → \
            \ `XI_2|ApplySingularUserScoreDelta`), so the user row, the score's vault totals and \
            \ `nzs-count` stay maintained by the single piece of code that already knows how. This \
            \ module never writes a base itself. \
            \ \
            \ EXECUTORLESS BY DESIGN (canon 2.2, as for `C_SyncTrueFungibleAnchors`): no actor's \
            \ authority is being exercised. The accounts named are SUBJECTS of a recomputation, not \
            \ signatories, and an executor slot would imply a permission deliberately not required \
            \ — see `AQP|C>BACKFILL-SCORE-SLICE` for why permissionless is the stronger position. \
            \ \
            \ WHAT IT DOES NOT REPAIR: an additive satellite's boosted/deb values. Those derive from \
            \ the HUB's base, so when a hub is re-rated its satellites go deb-stale and the EXISTING \
            \ staleness sweep fixes them — this recipe refuses satellites outright rather than write \
            \ a base that `URC_SingularUserScoreDeltaFromSignedUserBase` pins to 0.0."
        (P|UEV_IMC)
        (with-capability (AQP|C>BACKFILL-SCORE-SLICE patron pool-id score-id beneficiaries)
            (let
                (
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    ;;Scanned ONCE per transaction and threaded through every holder: the trackers
                    ;;cannot change inside this tx, so a per-holder rescan would be identical work.
                    (leg-rows:object (URH_AQP|ScoreBackfillLegRows pool-id))
                )
                (map
                    (lambda (b:string)
                        (ref-SCR::XE_ApplyRawBaseDelta b pool-id score-id
                            ;;target - current, both read HERE, after every earlier write in this map
                            (-
                                (URH_AQP|ScoreTargetBaseForBeneficiary
                                    pool-id score-id b
                                    (at "nat-rows" leg-rows)
                                    (at "frz-rows" leg-rows)
                                    (at "slp-rows" leg-rows))
                                (ref-SCR::UR_U-SCR|UserScoreBaseScore b pool-id score-id)
                            )
                        )
                    )
                    beneficiaries
                )
            )
        )
        (URCi_BackfillScoreSlice beneficiaries
            [(format "Re-rated {} holder(s) of score {} in pool {}"
                [(length beneficiaries) score-id pool-id])])
    )
    (defun C_BeginScoreRevoke:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string score-id:string)
        @doc "PHASE 1 of 3 — begin retiring <score-id> from <pool-id>: vacate its pool slot and \
            \ freeze the pool. Pool owner. \
            \ \
            \ WHY REVOKE NEEDED THREE PHASES AT ALL. `C_RevokeScore` refuses a score whose totals \
            \ are not zero, which is right -- cutting the link would strand that weight in the \
            \ score's totals and `nzs-count` with nothing left able to reverse it. But it also made \
            \ revoke unreachable on any pool somebody had staked into, because an admin cannot \
            \ unstake on a holder's behalf and there was no other way to reach zero. So the \
            \ requirement became a GOAL instead of a precondition: \
            \ \
            \   1] this vacates the SLOT, so the score stops being credited by new stakes \
            \   2] `Cp_DrainScoreSlice` retires the holders in parallel slices \
            \   3] `CC_FinalizeScoreRevoke` cuts the link once the work is provably done \
            \ \
            \ UNSLOTTED-BUT-STILL-LINKED IS THE PENDING-REVOKE MARKER, which is why none of this \
            \ needs a new column or a migration transaction: the asymmetry between the pool's slots \
            \ and the score's own link already expresses 'being retired', and the surviving link is \
            \ what still tells the orphan scan which pool those rows belong to. \
            \ \
            \ `C_RevokeScore` REMAINS the one-shot path for a score nobody holds weight in. This is \
            \ for the case that one refuses. EXECUTOR: pool owner, proven by `CAP_PoolOwner` plus \
            \ `UEV_ExecutorIzPoolOwner` in `AQP|C>BEGIN-SCORE-REVOKE` (canon 2.2)."
        (P|UEV_IMC)
        (let
            (
                (slot-index:integer (URC_ScoreSlotIndexForScore pool-id score-id))
            )
            (with-capability (AQP|C>BEGIN-SCORE-REVOKE patron executor pool-id score-id slot-index)
                (do
                    ;;1] the score stops being employed -- no new stake can credit it
                    (XI_RevokeScoreFromPool pool-id slot-index)
                    ;;2] freeze: a stake mid-drain would re-create the weight the drain retires
                    (WU_Pool|SweepInProgress pool-id true)
                    ;;The holder count is NOT reported here on purpose: reading it is a table scan,
                    ;;and a `C_` whose tree reaches one must be renamed `CC_` by the prefix canon.
                    ;;The caller reads `URHC_AQP|ScoreDrainOutstanding` itself to size its slices.
                    (URCi_BeginScoreRevoke
                        [(format "Score {} unslotted from pool {}: pool frozen. Drain its holders, finalize, then clear."
                            [score-id pool-id])])
                )
            )
        )
    )
    (defun Cp_DrainScoreSlice:object{IgnisCollectorV3.OutputCumulator}
        (patron:string pool-id:string score-id:string accounts:[string])
        @doc "PHASE 2 of 3 — HYDRA FED SLICE: retire exactly the listed holders of a score that is \
            \ mid-revoke, driving each stored base to 0.0. Run one per slice of \
            \ `URHC_AQP|ScoreDrainOutstanding`; order-independent and sendable in parallel. \
            \ \
            \ IDEMPOTENT FOR THE SAME REASON THE RE-RATE SLICE IS, but more simply: the target here \
            \ is 0.0 by definition, so a holder already drained yields a delta of exactly 0.0 and \
            \ nothing moves. A replayed slice, an overlapping slice and a repeated account are all \
            \ harmless, and no job state is needed -- `URHC_AQP|ScoreDrainOutstanding` reading [] IS \
            \ the completion record, and it is what phase 3 re-checks. \
            \ \
            \ EXECUTORLESS BY DESIGN (canon 2.2, as for the re-rate slice and the anchor syncs): the \
            \ accounts named are SUBJECTS of a retirement the pool owner already authorised in phase \
            \ 1, not signatories. Inventing an executor would imply a permission that is \
            \ deliberately not required."
        (P|UEV_IMC)
        (with-capability (AQP|C>DRAIN-SCORE-SLICE patron pool-id score-id accounts)
            (let
                (
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                )
                (map
                    (lambda (a:string) (ref-SCR::XE_DrainBase a pool-id score-id))
                    accounts
                )
            )
        )
        (URCi_DrainScoreSlice accounts
            [(format "Retired {} holder(s) of score {} in pool {}" [(length accounts) score-id pool-id])])
    )
    (defun CC_FinalizeScoreRevoke:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string pool-id:string score-id:string)
        @doc "PHASE 3 of 3 — cut the aqpool-link now that no holder carries weight for the score. \
            \ Pool owner. Refused while a single holder remains, re-reading the drain's own work \
            \ list rather than trusting a flag: with the link gone even the orphan scan loses the \
            \ pool those rows belonged to, so this is the last moment at which the remaining work \
            \ is still discoverable. \
            \ \
            \ Does NOT release the pool freeze -- `CC_ClearPoolSweep` does, and only when EVERY \
            \ score on the pool is clear. A pool mid-revoke on two scores must finish both. \
            \ EXECUTOR: pool owner, proven in `AQP|C>FINALIZE-SCORE-REVOKE` (canon 2.2)."
        (P|UEV_IMC)
        (UEV_AQP|ScoreDrainComplete pool-id score-id)
        (with-capability (AQP|C>FINALIZE-SCORE-REVOKE patron executor pool-id score-id)
            (let
                (
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                )
                (ref-SCR::XE_RevokeAqpoolLink score-id pool-id)
            )
        )
        (URCi_FinalizeScoreRevoke
            [(format "Score {} fully retired from pool {}: link cut. Pool stays frozen until CC_ClearPoolSweep."
                [score-id pool-id])])
    )
    (defun C_SyncTrueFungibleAnchors:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executee:string dptf-id:string)
        @doc "Pool-agnostic ANK repair when new TF anchors issued after stake. Reads BenDptfTotal, \
            \ refreshes promile, stamps last-ank-sync-count. SCORE boosted unchanged (lazy on next stake). \
            \ \
            \ EXECUTORLESS BY DESIGN, and <executee> is exactly that (canon 2.2, 2026-09-22). \
            \ The capability validates that the beneficiary EXISTS and is a standard account \
            \ (UEV_StakeBeneficiaryAccount) and nothing else; it is never ownership-checked. \
            \ Acted upon, needing no signature, only type-validated: the executee test \
            \ verbatim, and the same disposition DPDC-I reached for <creator-account> under \
            \ audit #53L. \
            \ \
            \ There is NO executor to name, and inventing one would be worse than none (4f). \
            \ This is permissionless maintenance: it recomputes anchor values from the \
            \ beneficiary's ACTUAL balances, so every outcome is the truth, and the PATRON pays \
            \ for it. A third party -- typically whoever issued the new anchors that made the \
            \ values stale -- can and should be able to trigger the repair. Requiring the \
            \ beneficiary's signature would remove that path and protect nothing: the only \
            \ thing a caller can do here is make someone else's data correct at their own \
            \ expense. \
            \ (patron/executor canon 2.2, EXECUTORLESS + executee, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (AQP|C>SYNC-TF-ANCHORS patron executee dptf-id)
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (total:decimal (UR_AQP|BenDptfTotalBalance executee dptf-id))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    (ico-ank:object{IgnisCollectorV3.OutputCumulator}
                        (ref-ANK::XE_UpdateTrueFungibleUserAnchorValues executee dptf-id total)
                    )
                    (ico-meta:object{IgnisCollectorV3.OutputCumulator}
                        (XB_SetBenDptfAnkSyncCount executee dptf-id)
                    )
                    (ico-gas:object{IgnisCollectorV3.OutputCumulator}
                        (URCi_SyncTrueFungibleAnchors [executee dptf-id])
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico-ank ico-meta ico-gas] [])
            )
        )
    )
    (defun C_SyncCollectableAnchors:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executee:string collectable-id:string son:bool)
        @doc "Pool-agnostic ANK repair for DPSF (son=true) or DPNF (son=false). Reads Ben* nonce rollup, \
            \ absolute resync via AQP-ANK::XE_Resync*, stamps Ben*AnkMeta. Talos splits SF/NF shells. \
            \ URD inventory is read before with-capability (select illegal in defcap). \
            \ \
            \ EXECUTORLESS BY DESIGN, and <executee> is the EXECUTEE (patron/executor \
            \ canon 2.2, 2026-09-22). The capability validates that the beneficiary EXISTS and \
            \ is a standard account (UEV_StakeBeneficiaryAccount) and nothing else -- it is \
            \ never ownership-checked. Acted upon, needing no signature, only type-validated: \
            \ the executee test verbatim, and the same disposition DPDC-I reached for \
            \ <creator-account> under audit #53L. \
            \ \
            \ There is NO executor to name, and inventing one would be worse than none (4f). \
            \ This is permissionless maintenance: it recomputes anchor values from the \
            \ beneficiary's ACTUAL balances, so every outcome is the truth, and the PATRON pays \
            \ for it. A third party -- typically whoever issued the new anchors that made the \
            \ values stale -- can and should be able to trigger the repair. Requiring the \
            \ beneficiary's signature would remove that path and protect nothing: the only \
            \ thing a caller can do here is make someone else's data correct at their own \
            \ expense. \
            \ (patron/executor canon 2.2, EXECUTORLESS + executee, 2026-09-22.)"
        (P|UEV_IMC)
        (let
            (
                (supplies:[object]
                    (if son
                        (URH_AQP|BenDpsfActiveNonceSupplies executee collectable-id)
                        (URH_AQP|BenDpnfActiveNonceSupplies executee collectable-id)
                    )
                )
            )
            (with-capability (AQP|C>SYNC-COLLECTABLE-ANCHORS patron executee collectable-id son)
                (let
                    (
                        (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        ;;
                        (nonces:[integer] (map (at "nonce") supplies))
                        (nonce-amounts:[integer] (map (at "amount") supplies))
                        (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                        (ico-ank:object{IgnisCollectorV3.OutputCumulator}
                            (if son
                                (ref-ANK::XE_ResyncSemiFungibleUserAnchorValues
                                    executee collectable-id nonces nonce-amounts
                                )
                                (ref-ANK::XE_ResyncNonFungibleUserAnchorValues
                                    executee collectable-id nonces
                                )
                            )
                        )
                        (ico-meta:object{IgnisCollectorV3.OutputCumulator}
                            (XB_SetBenCollectableAnkSyncCount executee collectable-id son)
                        )
                        (ico-gas:object{IgnisCollectorV3.OutputCumulator}
                            (URCi_SyncCollectableAnchors [executee collectable-id])
                        )
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico-ank ico-meta ico-gas] [])
                )
            )
        )
    )

)



;;

;; --- tables for 03_AQP.pact (13 defined) ---
;; NEW MODULE this round -- not live on chain, so its tables do
;; not exist yet and these create-table calls are ACTIVE.
(create-table P|T)
(create-table P|MT)
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
(create-table AQP|T|UserOccupancy)

