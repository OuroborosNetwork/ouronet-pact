;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 2 of 3
;; This is STEP 2 of 3 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-1 must have run first, including the init steps between deploys.
;; 2 source file(s), 214,916 gas measured in the REPL gas model, 303,902 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact
;;   2_CITIZEN/5_VaultsMinter/04_AQP-BOOT.pact
;;
;; TOTAL: 1 interface(s), 2 module(s), 2 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact
;;      interface  TalosStageTwo_ClientThreeV7
;;      module     TS02-C3
;;      table      P|T
;;      table      P|MT
;;   -- 2_CITIZEN/5_VaultsMinter/04_AQP-BOOT.pact
;;      module     AQP-BOOT
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact ================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/03_Talos.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface TalosStageTwo_ClientThreeV7
    @doc "Exposes Stage Two Third Batch of Client Functions: \
        \ the AcquisitionPools Client Functions"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions

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
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URCi_IssueGenericEarningVault:object{IgnisCollectorV4.OutputCumulator}
        (owner-konto:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [VCT] -- per-leg vacate. ONE transaction each, standalone, for a pool owner who wants to
    ;;  clear a single asset leg rather than the whole pool (CC_FullVacate does that).
    ;;
    ;;  RENAMED FROM `XB_` 2026-10-03, and the prefix was not a cosmetic error. `XB_` means
    ;;  "protected, used inside this module AND by a forward module" -- neither is true here:
    ;;  NOTHING in TS02-C3 calls these (measured: zero in-module callers) and no other module
    ;;  reaches them. They are ordinary Talos client entrypoints -- (patron, executor), P|TS,
    ;;  one core call, IGNIS on the patron, a format string -- identical in shape to every `C_`
    ;;  below, and they were simply named after their CALLEE (`AQP-VCT::XB_Vacate*`) instead of
    ;;  after their own band.
    ;;
    ;;  The consequence was not cosmetic either. `_registry.py`'s entrypoint filter is
    ;;  `^[A-Za-z0-9|_-]*\|C{1,2}p?_[A-Za-z0-9]+$`, which an `XB_` name cannot match -- so four
    ;;  live client operations were ABSENT from OURONET-REGISTRY.json and therefore unreachable
    ;;  from OuronetUI, unpriced in the IGNIS sheet, and invisible to every gate built on it.
    ;;  They were also the ONLY `X*`-named definitions in all eleven Talos modules.
    ;;
    (defun AQP-POOL|CC_VacateTrueFungible:string (patron:string executor:string pool-id:string))
    (defun AQP-POOL|CC_VacateOrtoFungible:string (patron:string executor:string pool-id:string dpof-id:string))
    (defun AQP-POOL|CC_VacateSemiFungible:string (patron:string executor:string pool-id:string dpsf-id:string))
    (defun AQP-POOL|CC_VacateNonFungible:string (patron:string executor:string pool-id:string dpnf-id:string))
    ;;
    ;;  [ANK]
    ;;
    (defun AQP-ANK|C_RevokeBoostClass:string (patron:string executor:string boost-class-id:string))
    (defun AQP-ANK|C_IssueTrueFungibleAnchor:string
        (patron:string executor:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
    )
    (defun AQP-ANK|C_IssueSemiFungibleAnchor:string
        (patron:string executor:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
    )
    (defun AQP-ANK|C_IssueNonFungibleAnchor:string
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
    )
    (defun AQP-ANK|C_IssueNonFungibleSetAnchor:string
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
    )
    (defun AQP-ANK|C_RevokeAnchor:string (patron:string executor:string anchor-id:string))
    ;;
    ;;  [AQP-SCORE]
    ;;
    (defun AQP-SCR|C_IssueLiquidityScore:string
        (patron:string executor:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
    )
    (defun AQP-SCR|C_IssueTrueFungibleScore:string
        (patron:string executor:string score-name:string precision:integer mx-frozen:decimal)
    )
    (defun AQP-SCR|C_IssueOrtoFungibleScore:string
        (patron:string executor:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
    )
    (defun AQP-SCR|C_IssueSemiFungibleScore:string
        (patron:string executor:string score-name:string precision:integer sft-equality:bool)
    )
    (defun AQP-SCR|C_IssueNonFungibleScore:string
        (patron:string executor:string score-name:string precision:integer nft-score-model:integer)
    )
    (defun AQP-SCR|C_RotateScoreOwnership:string (patron:string executor:string executee:string score-id:string))
    (defun AQP-SCR|C_ControlScore:string (patron:string executor:string score-id:string new-can-upgrade:bool new-can-change-owner:bool))
    (defun AQP-SCR|C_CreateScoreBoostClassLink:string (patron:string executor:string score-id:string boost-class-id:string))
    (defun AQP-SCR|C_CreateScoreBoostLink:string (patron:string executor:string score-id:string boost-score-id:string))
    (defun AQP-SCR|C_EnableDebBoost:string (patron:string executor:string score-id:string))
    (defun AQP-SCR|C_LockScoreDrift:string (patron:string executor:string score-id:string))
    (defun AQP-FVT|CC_LatchStreamEligible:string (patron:string executor:string fvt-id:string))
    (defun AQP-SCR|C_IssueTriplet:string
        (patron:string executor:string bronze-score-id:string silver-score-id:string golden-score-id:string)
    )
    (defun AQP-SCR|C_IssueSingleScoreModel:string
        (patron:string executor:string model-name:string score-class:integer collectable-id:string precision:integer nonces:[integer] nonce-score-values:[decimal] boost-class-id:string)
    )
    (defun AQP-SCR|C_CombineTripletScoreModel:string
        (patron:string executor:string model-name:string bronze-model-id:string silver-model-id:string golden-model-id:string)
    )
    (defun AQP-SCR|C_IssueScoreFromModel:string (patron:string executor:string model-id:string agency-name:string))
    (defun AQP-SCR|C_IssueSemiFungibleScoreDefinition:string
        (patron:string executor:string score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
    )
    (defun AQP-SCR|C_IssueNonFungibleScoreDefinition:string
        (patron:string executor:string score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
    )
    (defun AQP-SCR|C_IssueNonFungibleSetScoreDefinition:string
        (patron:string executor:string score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
    )
    ;;
    ;;  [AQP-POOL]
    ;;
    (defun AQP-POOL|C_Issue:string
        (patron:string executor:string pool-name:string asset-id:string aqp-class:integer)
    )
    (defun AQP-POOL|C_AddScore:string
        (patron:string executor:string pool-id:string score-id:string)
    )
    (defun AQP-POOL|C_RevokeScore:string
        (patron:string executor:string pool-id:string score-id:string)
    )
    (defun AQP-POOL|C_DisablePoolStake:string
        (patron:string executor:string pool-id:string)
    )
    (defun AQP-POOL|C_EnablePoolStake:string
        (patron:string executor:string pool-id:string)
    )
    ;;
    (defun AQP-POOL|CC_StakeSemiFungibleCollectable:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            collectable-id:string
            nonces:[integer]
        )
    )
    (defun AQP-POOL|CC_UnstakeSemiFungibleCollectable:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            collectable-id:string
            nonces:[integer]
            nonce-amounts:[integer]
        )
    )
    (defun AQP-POOL|CC_StakeNonFungibleCollectable:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            collectable-id:string
            nonces:[integer]
        )
    )
    (defun AQP-POOL|CC_UnstakeNonFungibleCollectable:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            collectable-id:string
            nonces:[integer]
            nonce-amounts:[integer]
        )
    )
    ;;
    (defun AQP-POOL|CC_StakeTrueFungible:string
        (patron:string executor:string executee:string pool-id:string dptf-id:string amount:decimal)
    )
    (defun AQP-POOL|CC_UnstakeTrueFungible:string
        (patron:string executor:string executee:string pool-id:string dptf-id:string amount:decimal)
    )
    (defun AQP-POOL|CC_StakeOrtoFungible:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            dpof-id:string
            nonces:[integer]
        )
    )
    (defun AQP-POOL|CC_UnstakeOrtoFungible:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            dpof-id:string
            nonces:[integer]
        )
    )
    (defun AQP-POOL|C_SyncTrueFungibleAnchors:string
        (patron:string executee:string dptf-id:string)
    )
    (defun AQP-POOL|C_SyncSemiFungibleAnchors:string
        (patron:string executee:string dpsf-id:string)
    )
    (defun AQP-POOL|C_SyncNonFungibleAnchors:string
        (patron:string executee:string dpnf-id:string)
    )
    (defun AQP-POOL|C_AbortVacate:string
        (patron:string executor:string pool-id:string)
    )
    (defun AQP-POOL|A_FinalizeVacate:string (pool-id:string))
    (defun AQP-POOL|CC_FullVacate:string (patron:string executor:string pool-id:string))
    (defun AQP-POOL|CCp_BatchVacateTrueFungible:string
        (patron:string pool-id:string dptf-id:string owner-ids:[string] beneficiary-ids:[string] amounts:[decimal]))
    (defun AQP-POOL|CCp_BatchVacateOrtoFungible:string
        (patron:string pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]]))
    (defun AQP-POOL|CCp_BatchVacateCollectables:string
        (patron:string pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]]))
    (defun AQP-POOL|AAp_BatchDrainTrueFungible:string
        (pool-id:string dptf-id:string owner-ids:[string] beneficiary-ids:[string] amounts:[decimal]))
    (defun AQP-POOL|AAp_BatchDrainOrtoFungible:string
        (pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]]))
    (defun AQP-POOL|AAp_BatchDrainCollectable:string
        (pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]]))
    ;;
    ;;  [AQP-FVT]
    ;;
    (defun AQP-FVT|C_Issue:string
        (patron:string executor:string fvt-name:string fvt-class:integer common-denominator:string)
    )
    (defun AQP-FVT|C_IssueMultipletFamily:string
        (
            patron:string
            executor:string
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
        )
    )
    (defun AQP-FVT|C_AddScoreEntity:string
        (patron:string executor:string fvt-id:string score-entity-type:integer score-entity-id:string)
    )
    (defun AQP-FVT|C_AddRewardLink:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
    )
    (defun AQP-FVT|C_ToggleScoreEntityLink:string
        (patron:string executor:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
    )
    (defun AQP-FVT|C_ToggleRewardLink:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string enabled:bool)
    )
    (defun AQP-FVT|C_SetMinInjectAmount:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string min-inject-amount:decimal)
    )
    (defun AQP-FVT|C_SetQualitySplit:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
    )
    (defun AQP-FVT|C_Control:string
        (patron:string executor:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
    )
    (defun AQP-FVT|C_RotateOwnership:string
        (patron:string executor:string executee:string fvt-id:string)
    )
    (defun AQP-FVT|C_SetCommonDenominator:string
        (patron:string executor:string fvt-id:string common-denominator:string)
    )
    (defun AQP-FVT|C_SetMosaic:string
        (patron:string executor:string fvt-id:string mosaic:bool)
    )
    (defun AQP-FVT|C_SetSplitMode:string
        (patron:string executor:string fvt-id:string split-mode:string)
    )
    (defun AQP-FVT|C_IssueGenericEarningVault:string
        (patron:string executor:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
    )
    (defun AQP-FVT|CC_InjectStream:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
    )
    (defun AQP-FVT|CC_Inject:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun AQP-FVT|CCp_InjectFixChunk:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
    )
    (defun AQP-FVT|CC_InjectFinalize:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun AQP-FVT|CCp_UnstaleAll:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
    )
    (defun MTX-AQP|2|CC_Inject:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun MTX-AQP|2|CC_SweepRevokeAnchor:string
        (patron:string executor:string anchor-id:string)
    )
    (defun AQP-FVT|CC_SweepRevokeAnchor:string
        (patron:string executor:string anchor-id:string)
    )
    (defun AQP-FVT|CC_SweepBegin:string
        (patron:string executor:string anchor-id:string)
    )
    (defun AQP-FVT|CCp_SweepRecomputeChunk:string
        (patron:string anchor-id:string chunk:integer)
    )
    (defun AQP-FVT|CC_UnstaleMyScores:string
        (patron:string executor:string fvt-ids:[string])
    )
    (defun AQP-FVT|CC_Collect:string
        (patron:string executor:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
    )
    ;;
    ;;  [AQP-EVCT]
    ;;
    ;;REWARD EVICTION, 2026-10-29. FOUR wrappers over TWO core functions, and the pairing is the
    ;;shape the owner asked for: "we could create 2 variants for this AA_/AAp that uses the gasless
    ;;patron, signaling its an Admin call, or CC_/CCp_ signaling its not an admin call for which
    ;;ignis has to be paid, and we can use the same name in the Talos orchestrator for it."
    ;;
    ;;ONE CORE PER SHAPE; ONLY THE PATRON AND THE GATE DIFFER. The AA_/AAp_ pair supplies
    ;;GOV|DALOS|SC_NAME -- the single account IGNIS::XE_CollectIgnis exempts via
    ;;`iz-gassles-patron` -- so the collection PATH still runs and the cumulator is still
    ;;consumed; it simply is not charged. The A-variant therefore cannot drift from the
    ;;C-variant's pricing, because it is the same call with a different account in slot 0.
    ;;
    ;;THE A-VARIANTS ARE ADMIN-GATED, AND THAT IS NOT DECORATION. AQP-EVCT's own gate is FVT
    ;;OWNERSHIP, not administration -- so a gasless wrapper carrying only P|TS would hand every
    ;;FVT owner in the system an unmetered IGNIS path, which is precisely the door narrowed to one
    ;;account on 2026-09-15 after RedTeam/[RT-I]_GasStation.repl. They gate on
    ;;P|ADMINISTRATIVE-SUMMONER instead (TS01-A's pattern, added to this module for them): the
    ;;admin keyset says the call MAY happen, <executor> says who made it happen, and AQP-EVCT still
    ;;requires that executor to own the FVT.
    ;;
    ;;TWO WRAPPERS RATHER THAN ONE WITH A BOOL: IG|COMPONENTS and the price sheet are keyed by
    ;;wrapper name, so a single entrypoint whose price is sometimes 0 and sometimes N has no honest
    ;;row.
    (defun AQP-EVCT|CCp_EvictMultiRewards:string
        (patron:string executor:string fvt-id:string beneficiaries:[string]
         score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string])
    )
    (defun AQP-EVCT|AAp_EvictMultiRewards:string
        (executor:string fvt-id:string beneficiaries:[string]
         score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string])
    )
    (defun AQP-EVCT|CC_EvictSingleReward:string
        (patron:string executor:string fvt-id:string beneficiary:string
         score-entity-type:integer score-entity-id:string reward-dptf-id:string)
    )
    (defun AQP-EVCT|AA_EvictSingleReward:string
        (executor:string fvt-id:string beneficiary:string
         score-entity-type:integer score-entity-id:string reward-dptf-id:string)
    )
    (defun AQP-EVCT|CC_FullEvictRewards:string
        (patron:string executor:string fvt-id:string)
    )
    (defun AQP-EVCT|AA_FullEvictRewards:string
        (executor:string fvt-id:string)
    )
    (defun AQP-DSA|C_DefineDelegationVault:string
        (patron:string executor:string fvt-id:string model-id:string unit-score:integer)
    )
    (defun AQP-DSA|CC_OpenAgency:string
        (patron:string executor:string fvt-id:string pool-id:string score-entity-id:string fee-per-mille:integer
         collectable-id:string stake-nonces:[integer])
    )
    (defun AQP-DSA|C_RecomputeCapture:string
        (patron:string fvt-id:string score-entity-id:string)
    )
    (defun AQP-DSA|C_SetOracleAuth:string
        (patron:string executor:string fvt-id:string oracle-guard:guard)
    )
    (defun AQP-DSA|C_OracleWrite:string
        (patron:string fvt-id:string score-entity-id:string nodes:integer uptime:integer)
    )
    (defun AQP-DSA|C_WithdrawRoyalty:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string)
    )
    (defun AQP-DSA|C_BurnRoyalty:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string)
    )
    (defun AQP-DSA|C_FuelRoyalty:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string swpair:string)
    )
    (defun AQP-DSA|C_SetAgencyFee:string
        (patron:string executor:string fvt-id:string score-entity-id:string fee-per-mille:integer)
    )
    (defun AQP-DSA|A_ToggleExternalOracle:string (patron:string executor:string on:bool))
    (defun AQP-DSA|A_SetOracleValidity:string (patron:string executor:string seconds:integer))


    ;;<=========================================================================>
    ;; ADDED 2026-10-12 -- interface-membership sweep (StoicSyntax-Prefixes.md Sec5,
    ;; owner ruling). Every one of these was already live in the module body; this
    ;; closes the gap between what the module DOES and what its interface SAYS it does.
    ;;<=========================================================================>
    (defun AQP-FVT|CC_ClearPoolSweep:string (patron:string pool-id:string))
    (defun AQP-FVT|CCp_FvtFixSlice:string (patron:string fvt-id:string reward-dptf-id:string users:[string]))
    (defun AQP-POOL|CC_FinalizeScoreRevoke:string (patron:string executor:string pool-id:string score-id:string))
    (defun AQP-POOL|CC_ReassignCollectableStakeBeneficiary:string (
            patron:string
            owner:string
            pool-id:string
            collectable-id:string
            son:bool
            nonce:integer
            current-beneficiary:string
            new-beneficiary:string
        ))
    (defun AQP-POOL|CC_ReassignOrtoStakeBeneficiary:string (
            patron:string
            owner:string
            pool-id:string
            dpof-id:string
            nonce:integer
            current-beneficiary:string
            new-beneficiary:string
        ))
    (defun AQP-POOL|CC_ReassignTrueFungibleStakeBeneficiary:string (
            patron:string
            owner:string
            pool-id:string
            dptf-id:string
            amount:decimal
            current-beneficiary:string
            new-beneficiary:string
        ))
    (defun AQP-POOL|CC_UpdateScoreMultipliers:string (patron:string executor:string score-id:string
         mx-frozen:decimal mx-sleeping:decimal mx-hibernated:decimal))
    (defun AQP-POOL|CCp_BackfillScoreSlice:string (patron:string pool-id:string score-id:string beneficiaries:[string]))
    (defun AQP-POOL|CCp_ReleaseSpecialCustodial:string (patron:string pool-id:string executee:string dpof-id:string nonce:integer))
    (defun AQP-POOL|CCp_StakeSpecialCustodial:string (
            patron:string
            executor:string
            executee:string
            pool-id:string
            dpof-id:string
            nonces:[integer]
        ))
    (defun AQP-POOL|C_BeginScoreRevoke:string (patron:string executor:string pool-id:string score-id:string))
    (defun AQP-POOL|Cp_DrainScoreSlice:string (patron:string pool-id:string score-id:string accounts:[string]))
    (defun UC_FormatStakeCollectableResult:string (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonce-count:integer
        ))
    (defun UC_FormatStakeOrtoFungibleResult:string (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonce-count:integer))
    (defun UC_FormatStakeTrueFungibleResult:string (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal))
    (defun UC_FormatUnstakeCollectableResult:string (pool-id:string owner-id:string collectable-id:string son:bool nonce-count:integer))
    (defun UC_FormatUnstakeOrtoFungibleResult:string (pool-id:string owner-id:string dpof-id:string nonce-count:integer))
    (defun UC_FormatUnstakeTrueFungibleResult:string (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal))
    (defun UC_FormatVacateCollectableResult:string (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonce-count:integer
        ))
    (defun UC_ShortAccount:string (account:string))
)
;;
(module TS02-C3 GOV
    @doc "TALOS Stage 2 Client Functiones Part 3 - Acquisition Pools Functions"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageTwo_ClientThreeV7)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    ;;Defaults for AQP-FVT|C_IssueGenericEarningVault. Named rather than inlined because each one
    ;;is a class rule a caller would otherwise have to know: getting any of them wrong builds a
    ;;vault that looks issued and cannot be staked.
    (defconst GV|PRECISION:integer                      6)
    (defconst GV|MX_FROZEN:decimal                      2.0)
    (defconst GV|POOL_CLASS_TF:integer                  1)      ;;aqp-class 1 = non-LP true fungible
    (defconst GV|FVT_CLASS_VAULT:integer                1)      ;;fvt-class 1 = Vault
    (defconst GV|SCORE_ENTITY_SCORE:integer             1)
    (defconst GV|COMMON_BAR:string                      "|")
    (defconst GOV|MD_TS02-C3                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS02-C3_ADMIN)))
    (defcap GOV|TS02-C3_ADMIN ()                        (enforce-guard GOV|MD_TS02-C3))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
    (defcap P|TS ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (gap:bool (ref-DALOS::UR_GAP))
            )
            (enforce (not gap) "While Global Administrative Pause is online, no client Functions can be executed")
            (compose-capability (P|TALOS-SUMMONER))
        )
    )
    (defcap P|TALOS-SUMMONER ()
        @doc "Talos Summoner Capability"
        true
    )
    (defcap P|ADMINISTRATIVE-SUMMONER ()
        @doc "ADMIN-GATED Talos summoner — P|TS plus this module's deploy keyset. Added 2026-10-29 for \
            \ the gasless reward-eviction pair (AQP-EVCT|AAp_EvictMultiRewards, AQP-EVCT|AA_FullEvictRewards), \
            \ copying TS01-A's capability of the same name. \
            \ \
            \ WHY A SEPARATE GATE EXISTS AT ALL: every other admin path in Talos reaches an `A_` core \
            \ that enforces its own GOV keyset, so P|TS is sufficient there. Reward eviction does not \
            \ -- AQP-EVCT gates on FVT OWNERSHIP -- so without this, a wrapper that supplies the \
            \ gasless patron would be an unmetered IGNIS path open to every FVT owner. \
            \ \
            \ It names no account: <executor> is the actor and AQP-EVCT still checks that it owns the \
            \ FVT. Composition order is authorisation-then-validation by way of P|TS, which carries \
            \ the GAP check."
        (compose-capability (P|TS))
        (compose-capability (GOV|TS02-C3_ADMIN))
    )
    ;;{P5}  functions
    (defun P|Info ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
        (with-capability (GOV|TS02-C3_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TS02-C3_ADMIN)
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
        (with-capability (GOV|TS02-C3_ADMIN)
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
        (with-capability (GOV|TS02-C3_ADMIN)
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
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (ref-P|ANK:module{OuronetPolicyV2} AQP-ANK)
                (ref-P|SCR:module{OuronetPolicyV2} AQP-SCORE)
                (ref-P|AQP:module{OuronetPolicyV2} AQP-POOL)
                (ref-P|FVT:module{OuronetPolicyV2} AQP-FVT)
                (ref-P|VCT:module{OuronetPolicyV2} AQP-VCT)
                (ref-P|ATSU:module{OuronetPolicyV2} ATSU)
                (ref-P|MTX-AQP:module{OuronetPolicyV2} MTX-AQP)
                (ref-P|DSA:module{OuronetPolicyV2} AQP-DSA)
                (ref-P|EVCT:module{OuronetPolicyV2} AQP-EVCT)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|TS01-A::P|A_AddIMP mg)
            (ref-P|ANK::P|A_AddIMP mg)
            (ref-P|SCR::P|A_AddIMP mg)
            (ref-P|AQP::P|A_AddIMP mg)
            (ref-P|FVT::P|A_AddIMP mg)
            (ref-P|VCT::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            ;; MTX-AQP defpact wrapper below — register the Talos summoner as an allowed IMC caller of MTX-AQP.
            (ref-P|MTX-AQP::P|A_AddIMP mg)
            ;; DSA vault/agency wrappers below — register the Talos summoner as an allowed IMC caller of AQP-DSA.
            (ref-P|DSA::P|A_AddIMP mg)
            ;; Reward-eviction wrappers below — register the Talos summoner as an allowed IMC caller
            ;; of AQP-EVCT. Both of its client entrypoints open with P|UEV_IMC, so without this row
            ;; every AQP-EVCT|* wrapper dies with "None of the guards passed".
            (ref-P|EVCT::P|A_AddIMP mg)
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
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    ;;
    ;;  ONE EVENT PER CORE FUNCTION CALLED -- owner ruling, 2026-10-14.
    ;;
    ;;  A Talos shell that merely FORWARDS to a core function must not carry `@event`: the core
    ;;  module's own capability already emits one, and two capabilities firing for a single
    ;;  operation puts two near-identical events on one transaction, which is what the explorer
    ;;  showed for `CC_ReassignTrueFungibleStakeBeneficiary` (`FVT|C>REASSIGN-TRUE-FUNGIBLE-
    ;;  BENEFICIARY` from AQP-FVT *and* `AQP|C>REASSIGN-TRUE-FUNGIBLE-BENEFICIARY` from here).
    ;;  `P|TS` alone is enough for the gas/IMC scope these shells exist to provide.
    ;;
    ;;  THE EXCEPTION, and the only one: where the core function being called carries NO evented
    ;;  capability of its own, the Talos cap is the single event and stays. That is why the nine
    ;;  stake/unstake caps below KEEP `@event` -- `FVT|C>TRUE-FUNGIBLE-STAKE-FLOW`,
    ;;  `FVT|C>ORTO-FUNGIBLE-STAKE-FLOW` and `FVT|C>COLLECTABLE-STAKE-FLOW` are not evented, and
    ;;  one shared `direction:bool` recipe cap could not tell a stake from an unstake anyway.
    ;;  Stripping those would leave the entire AQP stake surface with no event at all.
    ;;
    ;;  Orchestration is NOT an exception: a shell that drives several evented core functions
    ;;  legitimately shows several events -- one per real operation -- and still adds none here.
    ;;
    ;;  Measured before the change: 23 of this module's 28 defcaps were evented, against ZERO in
    ;;  every other Talos module in the tree (all six Stage-1 Talos, TS02-C1, TS02-C2, TS02-DPAD).
    ;;  14 stripped here; 9 kept under the exception above.
    (defcap AQP|C>STAKE-TRUE-FUNGIBLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "AQP client event: stake TrueFungible. Composes P|TS only; sovereign recipe in FVT::CC_TrueFungibleStakeFlow."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>UNSTAKE-TRUE-FUNGIBLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "AQP client event: unstake TrueFungible. Composes P|TS only; sovereign recipe in FVT::CC_TrueFungibleStakeFlow."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>STAKE-SPECIAL-CUSTODIAL
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string
         nonces:[integer] nonce-amounts:[decimal])
        @doc "AQP client event: stake SLEEPING batches under pool custody. Composes P|TS only. \
            \ Distinct from `AQP|C>STAKE-ORTO-FUNGIBLE` so the explorer can tell a custodial stake \
            \ from an ordinary one -- they differ in who the tracker names as owner, which is \
            \ exactly the fact an observer needs and cannot otherwise see."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>RELEASE-SPECIAL-CUSTODIAL
        (patron:string pool-id:string beneficiary-id:string dpof-id:string nonce:integer)
        @doc "AQP client gate: release a MATURED custodial sleeping position. Composes P|TS only; \
            \ maturity is enforced by VST and custody by AQP-FVT. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-FVT::FVT|C>RELEASE-SPECIAL-CUSTODIAL,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>STAKE-ORTO-FUNGIBLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal])
        @doc "AQP client event: stake OrtoFungible. nonces and nonce-amounts are resolved before this cap \
            \ (DPOF::UR_NoncesSupplies — whole nonce only) so the explorer records the exact legs moved."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>UNSTAKE-ORTO-FUNGIBLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal])
        @doc "AQP client event: unstake OrtoFungible. nonces and nonce-amounts resolved before this cap \
            \ (DPOF::UR_NoncesSupplies — whole nonce only) for explorer visibility."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>STAKE-SEMI-FUNGIBLE-COLLECTABLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "AQP client event: stake DPSF collectable (son=true). Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>UNSTAKE-SEMI-FUNGIBLE-COLLECTABLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "AQP client event: unstake DPSF collectable (son=true). Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>STAKE-NON-FUNGIBLE-COLLECTABLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "AQP client event: stake DPNF collectable (son=false). Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>UNSTAKE-NON-FUNGIBLE-COLLECTABLE
        (patron:string pool-id:string owner-id:string beneficiary-id:string collectable-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "AQP client event: unstake DPNF collectable (son=false). Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>UPDATE-SCORE-MULTIPLIERS
        (patron:string executor:string score-id:string
         mx-frozen:decimal mx-sleeping:decimal mx-hibernated:decimal)
        @doc "AQP client gate: re-set a score's frozen/sleeping multipliers. Composes P|TS only. \
            \ THE TALOS MIRROR CARRIES NO VALIDATION, deliberately and like its siblings: acquiring \
            \ it is what puts a registered inter-module guard in scope so the core client's \
            \ `P|UEV_IMC` passes. The real conditions — the emptiness gate in AQP-POOL, and \
            \ ownership plus the ordering invariant in AQP-SCORE — are enforced by the modules that \
            \ can actually see what they are checking. Duplicating them here would be a second \
            \ copy free to drift. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>UPDATE-SCORE-MULTIPLIERS,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>BEGIN-SCORE-REVOKE
        (patron:string executor:string pool-id:string score-id:string slot-index:integer)
        @doc "AQP client gate: phase 1 of a score revoke — vacate the slot, freeze the pool. \
            \ Composes P|TS only; the conditions live in AQP-POOL, which can see the slots. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>BEGIN-SCORE-REVOKE,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>DRAIN-SCORE-SLICE
        (patron:string pool-id:string score-id:string accounts:[string])
        @doc "AQP client gate: phase 2 — one fed slice of a score drain. Composes P|TS only. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>DRAIN-SCORE-SLICE,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>FINALIZE-SCORE-REVOKE
        (patron:string executor:string pool-id:string score-id:string)
        @doc "AQP client gate: phase 3 — cut the aqpool-link once the drain is complete. \
            \ Composes P|TS only. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>FINALIZE-SCORE-REVOKE,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>REASSIGN-ORTO-BENEFICIARY
        (patron:string owner:string pool-id:string dpof-id:string nonce:integer
         current-beneficiary:string new-beneficiary:string)
        @doc "AQP client gate: redirect who earns from an already-staked orto position, custody \
            \ or not. Composes P|TS only -- the conditions live in AQP-FVT, which can see the \
            \ tracker row. Renamed from AQP|C>REASSIGN-CUSTODIAL-BENEFICIARY, 2026-10-11: custody \
            \ is retired, so this now covers every staked sleeping position, not only one locked \
            \ under the pool's name. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-FVT::FVT|C>REASSIGN-ORTO-BENEFICIARY,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>REASSIGN-COLLECTABLE-BENEFICIARY
        (patron:string owner:string pool-id:string collectable-id:string son:bool nonce:integer
         current-beneficiary:string new-beneficiary:string)
        @doc "AQP client gate: the NFT/SFT counterpart of AQP|C>REASSIGN-ORTO-BENEFICIARY. \
            \ Composes P|TS only -- the conditions live in AQP-FVT. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-FVT::FVT|C>REASSIGN-COLLECTABLE-BENEFICIARY,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>REASSIGN-TRUE-FUNGIBLE-BENEFICIARY
        (patron:string owner:string pool-id:string dptf-id:string amount:decimal
         current-beneficiary:string new-beneficiary:string)
        @doc "AQP client gate: the TF counterpart of AQP|C>REASSIGN-ORTO-BENEFICIARY -- redirect \
            \ who earns from an already-staked true-fungible position, native or frozen, in whole \
            \ or in part. Composes P|TS only -- the conditions live in AQP-FVT, which can see the \
            \ tracker row. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-FVT::FVT|C>REASSIGN-TRUE-FUNGIBLE-BENEFICIARY,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap FVT|C>CLEAR-POOL-SWEEP
        (patron:string pool-id:string)
        @doc "AQP-FVT client gate: release a pool's sweep freeze. Composes P|TS only. \
            \ Mirrors AQP-FVT's cap, not AQP-POOL's: the release lives in AQP-FVT because the \
            \ freeze has two owners and only that module can see both. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-FVT::FVT|C>CLEAR-POOL-SWEEP,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>BACKFILL-SCORE-SLICE
        (patron:string pool-id:string score-id:string beneficiaries:[string])
        @doc "AQP client gate: one fed slice of the score re-rate sweep. Composes P|TS only. \
            \ No validation here, as for every mirror beside it — acquiring this is what puts a \
            \ registered inter-module guard in scope so the core client's `P|UEV_IMC` passes, and \
            \ the real conditions live in AQP-POOL, the only module that can see the tracker. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>BACKFILL-SCORE-SLICE,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>SYNC-TF-ANCHORS
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "AQP client gate: pool-agnostic TF anchor repair. Composes P|TS only. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>SYNC-TF-ANCHORS,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>SYNC-SEMI-FUNGIBLE-ANCHORS
        (patron:string beneficiary-id:string dpsf-id:string)
        @doc "AQP client gate: pool-agnostic DPSF anchor repair. Composes P|TS only. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>SYNC-COLLECTABLE-ANCHORS,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>SYNC-NON-FUNGIBLE-ANCHORS
        (patron:string beneficiary-id:string dpnf-id:string)
        @doc "AQP client gate: pool-agnostic DPNF anchor repair. Composes P|TS only. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-POOL::AQP|C>SYNC-COLLECTABLE-ANCHORS,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
    )
    (defcap AQP|C>ABORT-VACATE
        (patron:string pool-id:string)
        @doc "AQP client gate: clear vacate-in-progress (stake stays disabled). Composes P|TS only. \
            \ NOT EVENTED: the single event for this operation is\
            \ AQP-VCT::VCT|C>ABORT-VACATE-POOL,\
            \ which this shell forwards to -- see the {C3} banner for the rule."
        (compose-capability (P|TS))
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
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_ShortAccount:string (account:string)
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
            )
            (ref-I|OURONET::OI|UC_ShortAccount account)
        )
    )
    (defun UC_FormatStakeTrueFungibleResult:string
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Stake success text: self-stake when owner=beneficiary; else names short owner and beneficiary."
        (if (= owner-id beneficiary-id)
            (format "Successfully staked TrueFungible {} amount {} into Pool {} (self-stake, {}). "
                [dptf-id amount pool-id (UC_ShortAccount owner-id)]
            )
            (format "Successfully staked TrueFungible {} amount {} into Pool {} for beneficiary {} (owner {}). "
                [dptf-id amount pool-id (UC_ShortAccount beneficiary-id) (UC_ShortAccount owner-id)]
            )
        )
    )
    (defun UC_FormatUnstakeTrueFungibleResult:string
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Unstake success text: self-stake when owner=beneficiary; else names short owner and beneficiary."
        (if (= owner-id beneficiary-id)
            (format "Successfully unstaked TrueFungible {} amount {} from Pool {} (self-stake, {}). "
                [dptf-id amount pool-id (UC_ShortAccount owner-id)]
            )
            (format "Successfully unstaked TrueFungible {} amount {} from Pool {} for beneficiary {} (owner {}). "
                [dptf-id amount pool-id (UC_ShortAccount beneficiary-id) (UC_ShortAccount owner-id)]
            )
        )
    )
    (defun UC_FormatStakeOrtoFungibleResult:string
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonce-count:integer)
        @doc "Stake OF success text (whole-nonce Transfer)."
        (if (= owner-id beneficiary-id)
            (format "Successfully staked OrtoFungible {} ({} whole nonces) into Pool {} (self-stake, {}). "
                [
                    dpof-id
                    nonce-count
                    pool-id
                    (UC_ShortAccount owner-id)
                ]
            )
            (format "Successfully staked OrtoFungible {} ({} whole nonces) into Pool {} for beneficiary {} (owner {}). "
                [
                    dpof-id
                    nonce-count
                    pool-id
                    (UC_ShortAccount beneficiary-id)
                    (UC_ShortAccount owner-id)
                ]
            )
        )
    )
    (defun UC_FormatUnstakeOrtoFungibleResult:string
        (pool-id:string owner-id:string dpof-id:string nonce-count:integer)
        @doc "Unstake OF success text; beneficiary resolved from tracker in sovereign phase 1."
        (format "Successfully unstaked OrtoFungible {} ({} whole nonces) from Pool {} (owner {}). "
            [
                dpof-id
                nonce-count
                pool-id
                (UC_ShortAccount owner-id)
            ]
        )
    )
    (defun UC_FormatStakeCollectableResult:string
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonce-count:integer
        )
        @doc "Stake collectable success text."
        (if (= owner-id beneficiary-id)
            (format "Successfully staked {} {} ({} nonces) into Pool {} (self-stake, {}). "
                [
                    (if son "DPSF" "DPNF")
                    collectable-id
                    nonce-count
                    pool-id
                    (UC_ShortAccount owner-id)
                ]
            )
            (format "Successfully staked {} {} ({} nonces) into Pool {} for beneficiary {} (owner {}). "
                [
                    (if son "DPSF" "DPNF")
                    collectable-id
                    nonce-count
                    pool-id
                    (UC_ShortAccount beneficiary-id)
                    (UC_ShortAccount owner-id)
                ]
            )
        )
    )
    (defun UC_FormatUnstakeCollectableResult:string
        (pool-id:string owner-id:string collectable-id:string son:bool nonce-count:integer)
        @doc "Unstake collectable success text."
        (format "Successfully unstaked {} {} ({} nonces) from Pool {} (owner {}). "
            [
                (if son "DPSF" "DPNF")
                collectable-id
                nonce-count
                pool-id
                (UC_ShortAccount owner-id)
            ]
        )
    )
    (defun UC_FormatVacateCollectableResult:string
        (
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonce-count:integer
        )
        @doc "Vacate collectable success text (pool-owner forced unstake)."
        (format "Successfully vacated {} {} ({} nonces) from Pool {} (owner {} → beneficiary {}). "
            [
                (if son "DPSF" "DPNF")
                collectable-id
                nonce-count
                pool-id
                (UC_ShortAccount owner-id)
                (UC_ShortAccount beneficiary-id)
            ]
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;ADDED 2026-09-19. The generic-vault cost reader. It lives HERE, under {5.3} Read, and not
    ;;beside the client function it prices: URCi_ is a reader, and the canonical section order
    ;;puts every UR/URC/URH/URCi/INFO in this block regardless of what consumes it.
    (defun URCi_IssueGenericEarningVault:object{IgnisCollectorV4.OutputCumulator}
        (owner-konto:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
        @doc "Cost reader for AQP-FVT|C_IssueGenericEarningVault: the six component cumulators, \
            \ concatenated exactly as the operation concatenates them."
        ;;WHY IT COMPOSES RATHER THAN NAMING A PRICE. The operation is six core calls; its cost is
        ;;whatever those six cost. Writing a standalone price here would be a SECOND definition of
        ;;the same number, free to drift from the first -- the failure this codebase has found in
        ;;its own artefacts repeatedly. Concatenating the same six readers the operation's own
        ;;cumulators come from means the preview cannot disagree with the charge by construction.
        ;;
        ;;The component readers live in four different modules, and two of them are on RPS rather
        ;;than FVT (AddScoreEntity, AddRewardLink) -- which is worth knowing, because looking for
        ;;them on FVT beside the ops they price finds nothing.
        (let*
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                ;;
                (score-name:string (concat [vault-name "Score"]))
                (pool-name:string (concat [vault-name "Pool"]))
                (fvt-name:string (concat [vault-name "Vault"]))
                (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                (pool-id:string (ref-U|DALOS::UDC_Makeid pool-name))
                (fvt-id:string (ref-U|DALOS::UDC_Makeid fvt-name))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-SCR::URCi_IssueScore owner-konto [score-id])
                    (ref-AQP::URCi_Issue [pool-id])
                    (ref-AQP::URCi_AddScore [pool-id score-id])
                    (ref-FVT::URCi_Issue owner-konto [fvt-id])
                    ;;THE LAST TWO ARE BUILT HERE RATHER THAN CALLED, and the reason is specific.
                    ;;RPS::URCi_AddScoreEntity and URCi_AddRewardLink resolve their active-account
                    ;;with `UR_FVT|OwnerKonto fvt-id` -- a READ of the FVT row. For a PREVIEW of a
                    ;;vault that does not exist yet, that row is absent and the reader aborts:
                    ;;  No value found in table RPS_FVT|T|RewardAggregate for key: <name>Vault-...
                    ;;A cost preview for a CREATION operation cannot depend on reading the thing it
                    ;;is about to create. (Found by running it; the RT-K family is about exactly
                    ;;this class of preview/exec divergence.)
                    ;;
                    ;;The PRICE is not the problem -- it is static, from the same price-table keys
                    ;;below. Only the active-account came from the row, and here it is `owner-konto`,
                    ;;which the caller supplies. So these two use the identical UC_IgnisPrice keys
                    ;;and substitute the account. No price is restated; nothing can drift.
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisPrice "AQP-FVT|C_AddScoreEntity" "add-score-entity")
                        owner-konto (ref-IGNIS::URC_IsVirtualGasZero) [fvt-id score-id])
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisPrice "AQP-FVT|C_AddRewardLink" "add-reward-link")
                        owner-konto (ref-IGNIS::URC_IsVirtualGasZero)
                        [fvt-id reward-dptf-id GV|COMMON_BAR])
                ]
                []
            )
        )
    )


    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-POOL|CC_VacateTrueFungible:string
        (patron:string executor:string pool-id:string)
        @doc "Vacate rehaul — pool-owner vacate of a pool's TrueFungible leg only (one tx; used standalone or by \
            \ the agnostic CC_FullVacate for a class-1 TF+OF pool). Owner enforced in VCT|C>VACATE; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::XB_VacateTrueFungible executor pool-id))
                (format "Successfully vacated the TrueFungible leg of Pool {}." [pool-id])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-POOL|CC_VacateOrtoFungible:string
        (patron:string executor:string pool-id:string dpof-id:string)
        @doc "Vacate rehaul — pool-owner vacate of ONE OrtoFungible asset of a pool (one tx; standalone or per \
            \ class-1 satellite). Owner enforced in VCT|C>VACATE; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::XB_VacateOrtoFungible patron executor pool-id dpof-id))
                (format "Successfully vacated OrtoFungible {} of Pool {}." [dpof-id pool-id])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-POOL|CC_VacateSemiFungible:string
        (patron:string executor:string pool-id:string dpsf-id:string)
        @doc "Vacate rehaul — pool-owner vacate of the DPSF (semi-fungible) collection of a class-3 pool (one tx). \
            \ Owner enforced in VCT|C>VACATE; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::XB_VacateSemiFungible executor pool-id dpsf-id))
                (format "Successfully vacated SemiFungible {} of Pool {}." [dpsf-id pool-id])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-POOL|CC_VacateNonFungible:string
        (patron:string executor:string pool-id:string dpnf-id:string)
        @doc "Vacate rehaul — pool-owner vacate of the DPNF (non-fungible) collection of a class-4 pool (one tx). \
            \ Owner enforced in VCT|C>VACATE; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::XB_VacateNonFungible executor pool-id dpnf-id))
                (format "Successfully vacated NonFungible {} of Pool {}." [dpnf-id pool-id])
            )
        )
    )
    (defun AQP-DSA|C_DefineDelegationVault:string
        (patron:string executor:string fvt-id:string model-id:string unit-score:integer)
        @doc "DSA (Talos): bind a class-0 FVT as a delegation vault (score-entity model + unit-score); collects \
            \ IGNIS on patron. Only the FVT owner may run it."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DSA::C_DefineDelegationVault patron executor fvt-id model-id unit-score)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "DSA vault defined on FVT {} (model {}, unit-score {})." [fvt-id model-id unit-score])
            )
        )
    )
    (defun AQP-DSA|C_SetOracleAuth:string
        (patron:string executor:string fvt-id:string oracle-guard:guard)
        @doc "DSA (Talos): owner authorizes the delegated oracle key for a vault + arms the 25h capture expiry; \
            \ collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DSA::C_SetOracleAuth patron executor fvt-id oracle-guard)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Oracle authority set + oracle-on armed on FVT {}." [fvt-id])
            )
        )
    )
    (defun AQP-DSA|C_OracleWrite:string
        (patron:string fvt-id:string score-entity-id:string nodes:integer uptime:integer)
        @doc "DSA (Talos): the delegated oracle writes an agency's daily {nodes, uptime} + recomputes its capture \
            \ (fresh oracle-ts); collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DSA::C_OracleWrite patron fvt-id score-entity-id nodes uptime)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Oracle wrote nodes {} / uptime {}‰ for agency {}." [nodes uptime score-entity-id])
            )
        )
    )
    (defun AQP-DSA|C_WithdrawRoyalty:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string)
        @doc "DSA (Talos): the FVT owner withdraws the whole royalty pool of <reward-dptf-id> on vault <fvt-id> to \
            \ the owner konto; collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DSA::C_WithdrawRoyalty patron executor fvt-id reward-dptf-id)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Royalty pool of {} on FVT {} withdrawn to the owner." [reward-dptf-id fvt-id])
            )
        )
    )
    (defun AQP-DSA|C_BurnRoyalty:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string)
        @doc "DSA (Talos): the FVT owner BURNS the whole royalty pool of <reward-dptf-id> on vault <fvt-id>; \
            \ collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DSA::C_BurnRoyalty patron executor fvt-id reward-dptf-id)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Royalty pool of {} on FVT {} burned." [reward-dptf-id fvt-id])
            )
        )
    )
    (defun AQP-DSA|C_FuelRoyalty:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string swpair:string)
        @doc "DSA (Talos): the FVT owner FUELS <swpair> with the whole royalty pool of <reward-dptf-id> on vault \
            \ <fvt-id> (adds liquidity, no LP mint); collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DSA::C_FuelRoyalty patron executor fvt-id reward-dptf-id swpair)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Royalty pool of {} on FVT {} fueled into swpair {}." [reward-dptf-id fvt-id swpair])
            )
        )
    )
    (defun AQP-DSA|C_SetAgencyFee:string
        (patron:string executor:string fvt-id:string score-entity-id:string fee-per-mille:integer)
        @doc "DSA (Talos): the FVT owner changes a delegation agency's operator fee (reprices only future injects); \
            \ collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DSA::C_SetAgencyFee patron executor fvt-id score-entity-id fee-per-mille)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Agency {} fee set to {} per-mille." [score-entity-id fee-per-mille])
            )
        )
    )
    (defun AQP-DSA|A_ToggleExternalOracle:string (patron:string executor:string on:bool)
        @doc "DSA (Talos): MODULE ADMIN (GOV) flip of the SINGULAR GLOBAL external-oracle switch for ALL agencies. \
            \ No IGNIS billing (pure governance, master-signed, no OutputCumulator)."
        (with-capability (P|TS)
            (let
                (
                    (ref-DSA:module{DsaV3} AQP-DSA)
                )
                (ref-DSA::A_ToggleExternalOracle patron executor on)
                (format "Global external-oracle switch set to {}." [on])
            )
        )
    )
    (defun AQP-DSA|A_SetOracleValidity:string (patron:string executor:string seconds:integer)
        @doc "DSA (Talos): MODULE ADMIN (GOV) set of the GLOBAL oracle-validity window (freshness horizon, seconds). \
            \ No IGNIS billing (pure governance, master-signed, no OutputCumulator)."
        (with-capability (P|TS)
            (let
                (
                    (ref-DSA:module{DsaV3} AQP-DSA)
                )
                (ref-DSA::A_SetOracleValidity patron executor seconds)
                (format "Global oracle-validity window set to {} seconds." [seconds])
            )
        )
    )
    ;;
    (defun AQP-ANK|C_RevokeBoostClass:string
        (patron:string executor:string boost-class-id:string)
        @doc "Revokes an empty BoostClass."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ANK::C_RevokeBoostClass patron executor boost-class-id)
                )
                (format "Successfully revoked BoostClass {}." [boost-class-id])
            )
        )
    )
    (defun AQP-ANK|C_IssueTrueFungibleAnchor:string
        (patron:string executor:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Issues a DPTF Anchor. acnoi=true creates BoostClass inline (2x STOA); false links to existing (1x STOA)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-ANK::C_IssueTrueFungibleAnchor 
                            patron executor anchor-name dptf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dptf-amount
                        )
                    )
                    (out:[string] (at "output" ico))
                    (anchor-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (if acnoi
                    (format "Successfully issued TrueFungible Anchor {} (new BoostClass {}) for {}." [anchor-id (at 1 out) dptf-id])
                    (format "Successfully issued TrueFungible Anchor {} for {}." [anchor-id dptf-id])
                )
            )
        )
    )
    (defun AQP-ANK|C_IssueSemiFungibleAnchor:string
        (patron:string executor:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Issues a DPSF Anchor. acnoi=true creates BoostClass inline (2x STOA); false links to existing (1x STOA)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-ANK::C_IssueSemiFungibleAnchor 
                            patron executor anchor-name dpsf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpsf-nonce
                        )
                    )
                    (out:[string] (at "output" ico))
                    (anchor-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (if acnoi
                    (format "Successfully issued SemiFungible Anchor {} (new BoostClass {}) for {}." [anchor-id (at 1 out) dpsf-id])
                    (format "Successfully issued SemiFungible Anchor {} for {}." [anchor-id dpsf-id])
                )
            )
        )
    )
    (defun AQP-ANK|C_IssueNonFungibleAnchor:string
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Issues a DPNF trait-Anchor. acnoi=true creates BoostClass inline (2x STOA); false links to existing (1x STOA)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-ANK::C_IssueNonFungibleAnchor 
                            patron executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-trait-key dpnf-trait-value
                        )
                    )
                    (out:[string] (at "output" ico))
                    (anchor-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (if acnoi
                    (format "Successfully issued NonFungible Anchor {} (new BoostClass {}) for {}." [anchor-id (at 1 out) dpnf-id])
                    (format "Successfully issued NonFungible Anchor {} for {}." [anchor-id dpnf-id])
                )
            )
        )
    )
    (defun AQP-ANK|C_IssueNonFungibleSetAnchor:string
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Issues a DPNF set-Anchor. acnoi=true creates BoostClass inline (2x STOA); false links to existing (1x STOA)."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-ANK::C_IssueNonFungibleSetAnchor
                            patron executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-nonce-class
                        )
                    )
                    (out:[string] (at "output" ico))
                    (anchor-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (if acnoi
                    (format "Successfully issued NonFungible Set Anchor {} (new BoostClass {}) for {}." [anchor-id (at 1 out) dpnf-id])
                    (format "Successfully issued NonFungible Set Anchor {} for {}." [anchor-id dpnf-id])
                )
            )
        )
    )
    (defun AQP-ANK|C_RevokeAnchor:string (patron:string executor:string anchor-id:string)
        @doc "Revokes an existing Anchor, removing it from its BoostClass and AssetAnchors bookkeeping."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
                )
                (ref-IGNIS::XE_CollectIgnis patron 
                    (ref-ANK::C_RevokeAnchor patron executor anchor-id)
                )
                (format "Successfully revoked Anchor {}." [anchor-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueLiquidityScore:string
        (patron:string executor:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
        @doc "Issues score-class 0 (LP) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-SCR::C_IssueLiquidityScore patron executor score-name precision lp-denominator mx-frozen mx-sleeping)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED score-id, not `score-name`. The name is the caller's own
                ;;INPUT -- echoing it tells them nothing they did not already type, while the id
                ;;(`WonderCoach` -> `WonderCoach-nK4O_C00so9w`) is the only thing the transaction
                ;;produced and the key every later op takes. The core already threaded it out via
                ;;`URCi_IssueScore executor [score-id]`; this just stopped throwing it away.
                ;;StoicSyntax 2.16.2.
                (format "Successfully issued Liquidity Score {} for owner {}." [(at 0 (at "output" ico)) executor])
            )
        )
    )
    (defun AQP-SCR|C_IssueTrueFungibleScore:string
        (patron:string executor:string score-name:string precision:integer mx-frozen:decimal)
        @doc "Issues score-class 1 (DPTF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-SCR::C_IssueTrueFungibleScore patron executor score-name precision mx-frozen)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED score-id, not `score-name`. The name is the caller's own
                ;;INPUT -- echoing it tells them nothing they did not already type, while the id
                ;;(`WonderCoach` -> `WonderCoach-nK4O_C00so9w`) is the only thing the transaction
                ;;produced and the key every later op takes. The core already threaded it out via
                ;;`URCi_IssueScore executor [score-id]`; this just stopped throwing it away.
                ;;StoicSyntax 2.16.2.
                (format "Successfully issued TrueFungible Score {} for owner {}." [(at 0 (at "output" ico)) executor])
            )
        )
    )
    (defun AQP-SCR|C_IssueOrtoFungibleScore:string
        (patron:string executor:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Issues score-class 2 (DPOF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-SCR::C_IssueOrtoFungibleScore patron executor score-name precision mx-sleeping mx-hibernated)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED score-id, not `score-name`. The name is the caller's own
                ;;INPUT -- echoing it tells them nothing they did not already type, while the id
                ;;(`WonderCoach` -> `WonderCoach-nK4O_C00so9w`) is the only thing the transaction
                ;;produced and the key every later op takes. The core already threaded it out via
                ;;`URCi_IssueScore executor [score-id]`; this just stopped throwing it away.
                ;;StoicSyntax 2.16.2.
                (format "Successfully issued OrtoFungible Score {} for owner {}." [(at 0 (at "output" ico)) executor])
            )
        )
    )
    (defun AQP-SCR|C_IssueSemiFungibleScore:string
        (patron:string executor:string score-name:string precision:integer sft-equality:bool)
        @doc "Issues score-class 3 (DPSF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-SCR::C_IssueSemiFungibleScore patron executor score-name precision sft-equality)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED score-id, not `score-name`. The name is the caller's own
                ;;INPUT -- echoing it tells them nothing they did not already type, while the id
                ;;(`WonderCoach` -> `WonderCoach-nK4O_C00so9w`) is the only thing the transaction
                ;;produced and the key every later op takes. The core already threaded it out via
                ;;`URCi_IssueScore executor [score-id]`; this just stopped throwing it away.
                ;;StoicSyntax 2.16.2.
                (format "Successfully issued SemiFungible Score {} for owner {}." [(at 0 (at "output" ico)) executor])
            )
        )
    )
    (defun AQP-SCR|C_IssueNonFungibleScore:string
        (patron:string executor:string score-name:string precision:integer nft-score-model:integer)
        @doc "Issues score-class 4 (DPNF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-SCR::C_IssueNonFungibleScore patron executor score-name precision nft-score-model)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                ;;REPORTS THE GENERATED score-id, not `score-name`. The name is the caller's own
                ;;INPUT -- echoing it tells them nothing they did not already type, while the id
                ;;(`WonderCoach` -> `WonderCoach-nK4O_C00so9w`) is the only thing the transaction
                ;;produced and the key every later op takes. The core already threaded it out via
                ;;`URCi_IssueScore executor [score-id]`; this just stopped throwing it away.
                ;;StoicSyntax 2.16.2.
                (format "Successfully issued NonFungible Score {} for owner {}." [(at 0 (at "output" ico)) executor])
            )
        )
    )
    (defun AQP-SCR|C_RotateScoreOwnership:string (patron:string executor:string executee:string score-id:string)
        @doc "Rotates score ownership in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_RotateOwnership patron executor executee score-id))
                (format "Successfully rotated ownership for score {} to {}." [score-id executee])
            )
        )
    )
    (defun AQP-SCR|C_ControlScore:string (patron:string executor:string score-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Updates score control flags in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_Control patron executor score-id new-can-upgrade new-can-change-owner)
                )
                (format "Successfully updated control flags for score {}." [score-id])
            )
        )
    )
    (defun AQP-SCR|C_CreateScoreBoostClassLink:string (patron:string executor:string score-id:string boost-class-id:string)
        @doc "Creates score -> boost-class link in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_CreateBoostClassLink patron executor score-id boost-class-id))
                (format "Successfully linked score {} to BoostClass {}." [score-id boost-class-id])
            )
        )
    )
    (defun AQP-SCR|C_CreateScoreBoostLink:string (patron:string executor:string score-id:string boost-score-id:string)
        @doc "Creates score -> boost-score link in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_CreateBoostLink patron executor score-id boost-score-id))
                (format "Successfully linked score {} to boost score {}." [score-id boost-score-id])
            )
        )
    )
    (defun AQP-SCR|C_EnableDebBoost:string (patron:string executor:string score-id:string)
        @doc "Enables irreversible DEB boost on the score row. Medium IGNIS cost; no native STOA."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_EnableDebBoost patron executor score-id))
                (format "Successfully enabled DEB boost for score {}." [score-id])
            )
        )
    )
    (defun AQP-SCR|C_LockScoreDrift:string (patron:string executor:string score-id:string)
        @doc "Permanently marks a score drift-proof — irreversible. Refused unless the score is \
            \ already provably drift-free (deb-boost off, no boost-class link), and from then on \
            \ the score accepts neither. This is the per-score half of what a streaming FVT \
            \ requires; the FVT half is AQP-FVT|CC_LatchStreamEligible."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_LockScoreDrift patron executor score-id))
                (format "Score {} is now permanently drift-locked." [score-id])
            )
        )
    )
    (defun AQP-FVT|CC_LatchStreamEligible:string (patron:string executor:string fvt-id:string)
        @doc "Permanently latches an FVT as eligible for TIME-STREAMED injects — irreversible, and \
            \ HEAVY: it scans every enabled member and requires each to be drift-locked. Afterwards \
            \ the FVT admits and re-enables only drift-locked members. CC_InjectStream refuses \
            \ until this has been done."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-FVT::CC_LatchStreamEligible patron executor fvt-id))
                (format "FVT {} is now stream-eligible; its membership is permanently drift-locked." [fvt-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueTriplet:string
        (patron:string executor:string bronze-score-id:string silver-score-id:string golden-score-id:string)
        @doc "Issues SCR triplet bundle T|bronze|silver|golden and collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-SCR::C_IssueTriplet patron executor bronze-score-id silver-score-id golden-score-id)
                    )
                    (out:[string] (at "output" ico))
                    (triplet-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Successfully issued triplet {}." [triplet-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueSingleScoreModel:string
        (patron:string executor:string model-name:string score-class:integer collectable-id:string precision:integer nonces:[integer] nonce-score-values:[decimal] boost-class-id:string)
        @doc "Defines a SINGLE score-entity model in AQP-SCORE and collects IGNIS on patron. Returns the model-id."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-SCR::C_IssueSingleScoreModel patron executor model-name score-class collectable-id precision nonces nonce-score-values boost-class-id)
                    )
                    (model-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Successfully defined single score-entity model {}." [model-id])
            )
        )
    )
    (defun AQP-SCR|C_CombineTripletScoreModel:string
        (patron:string executor:string model-name:string bronze-model-id:string silver-model-id:string golden-model-id:string)
        @doc "Combines three single models into a TRIPLET score-entity model in AQP-SCORE and collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-SCR::C_CombineTripletScoreModel patron executor model-name bronze-model-id silver-model-id golden-model-id)
                    )
                    (model-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Successfully combined triplet score-entity model {}." [model-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueScoreFromModel:string (patron:string executor:string model-id:string agency-name:string)
        @doc "FACTORY (Talos): issue a conforming score entity from <model-id> for executor; collects IGNIS on \
            \ patron. Returns the (score | triplet) id."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-SCR::C_IssueScoreFromModel patron executor model-id agency-name)
                    )
                    (entity-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Successfully issued score entity {} from model {}." [entity-id model-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueSemiFungibleScoreDefinition:string
        (patron:string executor:string score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
        @doc "Writes DPSF nonce score definitions in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                ;;DEAD-DEFINITION GUARD (StoicSyntax 2.16, 2026-10-06). If this score is already
                ;;employed by a pool, the collection being defined must be the one that pool
                ;;stakes -- otherwise the rows save cleanly and score nothing forever. No-op
                ;;while aqpool-link is BAR, which is the normal state at definition time.
                ;;Here rather than in AQP-SCORE because the pool fact lives one module LATER in
                ;;deploy order: AQP-SCORE cannot reference AQP-POOL, only the reverse.
                (ref-AQP::UEV_ScoreDefinitionTargetMatchesPool score-id dpsf-id)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueSemiFungibleScoreDefinition patron executor score-id dpsf-id nonces nonce-score-values)
                )
                (format "Successfully issued SemiFungible score definitions for score {} and dpsf-id {}." [score-id dpsf-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueNonFungibleScoreDefinition:string
        (patron:string executor:string score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
        @doc "Writes DPNF trait score definitions in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                ;;DEAD-DEFINITION GUARD (StoicSyntax 2.16, 2026-10-06). If this score is already
                ;;employed by a pool, the collection being defined must be the one that pool
                ;;stakes -- otherwise the rows save cleanly and score nothing forever. No-op
                ;;while aqpool-link is BAR, which is the normal state at definition time.
                ;;Here rather than in AQP-SCORE because the pool fact lives one module LATER in
                ;;deploy order: AQP-SCORE cannot reference AQP-POOL, only the reverse.
                (ref-AQP::UEV_ScoreDefinitionTargetMatchesPool score-id dpnf-id)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueNonFungibleScoreDefinition patron executor score-id dpnf-id trait-keys trait-values trait-score-values)
                )
                (format "Successfully issued NonFungible score definitions for score {} and dpnf-id {}." [score-id dpnf-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueNonFungibleSetScoreDefinition:string
        (patron:string executor:string score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
        @doc "Writes DPNF set-mode (nonce-class) score definitions in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                ;;DEAD-DEFINITION GUARD (StoicSyntax 2.16, 2026-10-06). If this score is already
                ;;employed by a pool, the collection being defined must be the one that pool
                ;;stakes -- otherwise the rows save cleanly and score nothing forever. No-op
                ;;while aqpool-link is BAR, which is the normal state at definition time.
                ;;Here rather than in AQP-SCORE because the pool fact lives one module LATER in
                ;;deploy order: AQP-SCORE cannot reference AQP-POOL, only the reverse.
                (ref-AQP::UEV_ScoreDefinitionTargetMatchesPool score-id dpnf-id)
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueNonFungibleSetScoreDefinition patron executor score-id dpnf-id dpnf-nonce-classes class-score-values)
                )
                (format "Successfully issued NonFungible set score definitions for score {} and dpnf-id {}." [score-id dpnf-id])
            )
        )
    )
    (defun AQP-POOL|C_Issue:string
        (patron:string executor:string pool-name:string asset-id:string aqp-class:integer)
        @doc "Issues an acquisition pool (aqp-class + canonical native asset-id) and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-AQP::C_Issue patron executor pool-name asset-id aqp-class)
                    )
                    (out:[string] (at "output" ico))
                    (pool-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully issued Acquisition Pool {} (class {} for asset {})." [pool-id aqp-class asset-id])
            )
        )
    )
    (defun AQP-POOL|C_AddScore:string
        (patron:string executor:string pool-id:string score-id:string)
        @doc "Assigns score-id to the first free slot on pool-id; collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_AddScore patron executor pool-id score-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully assigned Score {} to Pool {}." [score-id pool-id])
            )
        )
    )
    (defun AQP-POOL|C_RevokeScore:string
        (patron:string executor:string pool-id:string score-id:string)
        @doc "Revokes score-id from pool-id (compact slots, clear aqpool-link); collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_RevokeScore patron executor pool-id score-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully revoked Score {} from Pool {}." [score-id pool-id])
            )
        )
    )
    (defun AQP-POOL|C_DisablePoolStake:string
        (patron:string executor:string pool-id:string)
        @doc "Pool owner pauses new stakes (stake-enabled → false); collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_DisablePoolStake patron executor pool-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully disabled staking on Pool {}." [pool-id])
            )
        )
    )
    (defun AQP-POOL|C_EnablePoolStake:string
        (patron:string executor:string pool-id:string)
        @doc "Pool owner re-enables new stakes (stake-enabled → true); collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_EnablePoolStake patron executor pool-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully enabled staking on Pool {}." [pool-id])
            )
        )
    )
    ;;
    (defun AQP-POOL|CC_StakeTrueFungible:string
        (patron:string executor:string executee:string pool-id:string dptf-id:string amount:decimal)
        @doc "Stake DPTF (or native|F| LP) into pool-id. Talos client shell: event cap + FVT::CC_TrueFungibleStakeFlow direction=true."
        (with-capability (AQP|C>STAKE-TRUE-FUNGIBLE patron pool-id executor executee dptf-id amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_TrueFungibleStakeFlow patron executor executee pool-id dptf-id amount true)
                )
                (UC_FormatStakeTrueFungibleResult pool-id executor executee dptf-id amount)
            )
        )
    )
    (defun AQP-POOL|CC_UnstakeTrueFungible:string
        (patron:string executor:string executee:string pool-id:string dptf-id:string amount:decimal)
        @doc "Unstake DPTF from pool-id. Talos client shell: event cap + FVT::CC_TrueFungibleStakeFlow direction=false."
        (with-capability (AQP|C>UNSTAKE-TRUE-FUNGIBLE patron pool-id executor executee dptf-id amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_TrueFungibleStakeFlow patron executor executee pool-id dptf-id amount false)
                )
                (UC_FormatUnstakeTrueFungibleResult pool-id executor executee dptf-id amount)
            )
        )
    )
    (defun AQP-POOL|CCp_StakeSpecialCustodial:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            dpof-id:string
            nonces:[integer]
        )
        @doc "Stake whole SLEEPING (Z|) nonces into a pool UNDER CUSTODY: the batches leave \
            \ <executor>, but the tracker records the pool as their owner, so they cannot be \
            \ withdrawn until the lock matures. Scores, rewards and claims still accrue to \
            \ <executee> exactly as on an ordinary stake. \
            \ \
            \ Release with `AQP-POOL|CCp_ReleaseSpecialCustodial`, which is PERMISSIONLESS once \
            \ the lock matures and can only pay the beneficiary -- so the time-lock is on the \
            \ asset, not on the staker's ability to get it back. Talos shell → \
            \ AQP-FVT::CCp_StakeSpecialCustodial."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[decimal] (ref-DPOF::UR_NoncesSupplies dpof-id nonces))
            )
            (with-capability
                (AQP|C>STAKE-SPECIAL-CUSTODIAL patron pool-id executor executee dpof-id nonces nonce-amounts)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CCp_StakeSpecialCustodial
                            patron executor executee pool-id dpof-id nonces nonce-amounts
                        )
                    )
                    (format "Staked {} sleeping nonce(s) of {} into pool {} under POOL CUSTODY for {}. Releasable only at maturity."
                        [nonce-count dpof-id pool-id (UC_ShortAccount executee)]
                    )
                )
            )
        )
    )
    (defun AQP-POOL|CCp_ReleaseSpecialCustodial:string
        (patron:string pool-id:string executee:string dpof-id:string nonce:integer)
        @doc "Release a MATURED custodial sleeping position: unwind the score and tracker, dissolve \
            \ the batch, and send the native counterpart to <executee>. Talos shell → \
            \ AQP-FVT::CCp_ReleaseSpecialCustodial. \
            \ \
            \ PERMISSIONLESS BY DESIGN, and that is what makes custody safe to accept: the staker \
            \ cannot trigger this themselves (the pool owns the tracker row), so if it needed the \
            \ pool owner's signature an absent owner could hold a matured position forever. Anyone \
            \ may call it and nobody can profit from doing so -- the native tokens go to the \
            \ beneficiary recorded in the tracker, never to the caller. \
            \ \
            \ Refused before maturity by `VST|XE>UNSLEEP`, the same gate a user's own unsleep must \
            \ pass."
        (with-capability
            (AQP|C>RELEASE-SPECIAL-CUSTODIAL patron pool-id executee dpof-id nonce)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CCp_ReleaseSpecialCustodial patron pool-id executee dpof-id nonce)
                )
                (format "Released sleeping nonce {} of {} from pool {}: batch dissolved, native sent to {}."
                    [nonce dpof-id pool-id (UC_ShortAccount executee)]
                )
            )
        )
    )
    (defun AQP-POOL|CC_ReassignOrtoStakeBeneficiary:string
        (
            patron:string
            owner:string
            pool-id:string
            dpof-id:string
            nonce:integer
            current-beneficiary:string
            new-beneficiary:string
        )
        @doc "Redirect who earns from an already-staked orto position -- including a sleeping \
            \ batch still inside its maturity lock -- without unstaking and restaking it. \
            \ RENAMED from AQP-POOL|CCp_ReassignCustodialBeneficiary, 2026-10-11: custody is \
            \ retired, <owner> stays the tracker owner throughout, and this works for any staked \
            \ sleeping position, not only one locked under the pool's name. \
            \ \
            \ NO ASSET EVER MOVES HERE OR AT RELEASE -- the ordinary unstake always returns the \
            \ position to <owner>, regardless of who the beneficiary was, so this is pure \
            \ earnings bookkeeping and the token's transfer rules have nothing to say about it. \
            \ \
            \ Requires the OWNER's signature -- they are the one entitled to decide who earns. \
            \ Talos shell → AQP-FVT::CC_ReassignOrtoStakeBeneficiary."
        (with-capability
            (AQP|C>REASSIGN-ORTO-BENEFICIARY
                patron owner pool-id dpof-id nonce current-beneficiary new-beneficiary)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_ReassignOrtoStakeBeneficiary
                        patron owner pool-id dpof-id nonce current-beneficiary new-beneficiary
                    )
                )
                (format "Nonce {} of {} in pool {} now earns for {} instead of {}; owner {} and the position are unchanged."
                    [nonce dpof-id pool-id (UC_ShortAccount new-beneficiary)
                     (UC_ShortAccount current-beneficiary) (UC_ShortAccount owner)]
                )
            )
        )
    )
    (defun AQP-POOL|CC_ReassignCollectableStakeBeneficiary:string
        (
            patron:string
            owner:string
            pool-id:string
            collectable-id:string
            son:bool
            nonce:integer
            current-beneficiary:string
            new-beneficiary:string
        )
        @doc "The NFT/SFT counterpart of AQP-POOL|CC_ReassignOrtoStakeBeneficiary. Collectables \
            \ carry no maturity lock -- this redirects earnings on an already-staked nonce \
            \ without an unstake/restake round trip. son=true DPSF, son=false DPNF. \
            \ Talos shell → AQP-FVT::CC_ReassignCollectableStakeBeneficiary."
        (with-capability
            (AQP|C>REASSIGN-COLLECTABLE-BENEFICIARY
                patron owner pool-id collectable-id son nonce current-beneficiary new-beneficiary)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_ReassignCollectableStakeBeneficiary
                        patron owner pool-id collectable-id son nonce current-beneficiary new-beneficiary
                    )
                )
                (format "Nonce {} of {} in pool {} now earns for {} instead of {}; owner {} and the position are unchanged."
                    [nonce collectable-id pool-id (UC_ShortAccount new-beneficiary)
                     (UC_ShortAccount current-beneficiary) (UC_ShortAccount owner)]
                )
            )
        )
    )
    (defun AQP-POOL|CC_ReassignTrueFungibleStakeBeneficiary:string
        (
            patron:string
            owner:string
            pool-id:string
            dptf-id:string
            amount:decimal
            current-beneficiary:string
            new-beneficiary:string
        )
        @doc "Redirect part or all of who earns from an already-staked true-fungible position -- \
            \ native or its `F|` frozen counterpart -- without unstaking and restaking it. \
            \ Unlike the OF/collectable reassigns, a TF position has no nonce, so <amount> may be \
            \ any value up to the current balance: the owner may split a position across two \
            \ beneficiaries, or move it whole. \
            \ \
            \ NO ASSET EVER MOVES -- the ordinary unstake always returns the position to <owner>, \
            \ regardless of who the beneficiary was, so this is pure earnings bookkeeping. \
            \ \
            \ Requires the OWNER's signature -- they are the one entitled to decide who earns. \
            \ Talos shell → AQP-FVT::CC_ReassignTrueFungibleStakeBeneficiary."
        (with-capability
            (AQP|C>REASSIGN-TRUE-FUNGIBLE-BENEFICIARY
                patron owner pool-id dptf-id amount current-beneficiary new-beneficiary)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_ReassignTrueFungibleStakeBeneficiary
                        patron owner pool-id dptf-id amount current-beneficiary new-beneficiary
                    )
                )
                (format "{} of {} in pool {} now earns for {} instead of {}; owner {} and the position are unchanged."
                    [amount dptf-id pool-id (UC_ShortAccount new-beneficiary)
                     (UC_ShortAccount current-beneficiary) (UC_ShortAccount owner)]
                )
            )
        )
    )
    (defun AQP-POOL|CC_StakeOrtoFungible:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            dpof-id:string
            nonces:[integer]
        )
        @doc "Stake whole DPOF nonces via C_Transfer. Poll DPOF::UR_NoncesSupplies, then @event cap with resolved legs."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[decimal] (ref-DPOF::UR_NoncesSupplies dpof-id nonces))
            )
            (with-capability (AQP|C>STAKE-ORTO-FUNGIBLE patron pool-id executor executee dpof-id nonces nonce-amounts)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_OrtoFungibleStakeFlow
                            patron executor executee pool-id dpof-id nonces nonce-amounts true
                        )
                    )
                    (UC_FormatStakeOrtoFungibleResult pool-id executor executee dpof-id nonce-count)
                )
            )
        )
    )
    (defun AQP-POOL|CC_UnstakeOrtoFungible:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            dpof-id:string
            nonces:[integer]
        )
        @doc "Unstake whole DPOF nonces via C_Transfer from the (owner, beneficiary) row. M5: executee is \
            \ caller-supplied (self OR foreign) so the exact staked row is located — mirrors TF. Poll UR_NoncesSupplies, \
            \ then @event cap with resolved legs."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[decimal] (ref-DPOF::UR_NoncesSupplies dpof-id nonces))
            )
            (with-capability (AQP|C>UNSTAKE-ORTO-FUNGIBLE patron pool-id executor executee dpof-id nonces nonce-amounts)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_OrtoFungibleStakeFlow
                            patron executor executee pool-id dpof-id nonces nonce-amounts false
                        )
                    )
                    (UC_FormatUnstakeOrtoFungibleResult pool-id executor dpof-id nonce-count)
                )
            )
        )
    )
    ;;
    (defun AQP-POOL|CC_StakeSemiFungibleCollectable:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            collectable-id:string
            nonces:[integer]
        )
        @doc "Stake DPSF collectable (son=true). Poll DPDC::UR_AccountNoncesSupplies, then FVT::CC_CollectableStakeFlow."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[integer] (ref-DPDC::UR_AccountNoncesSupplies executor collectable-id true nonces))
            )
            (with-capability
                (AQP|C>STAKE-SEMI-FUNGIBLE-COLLECTABLE
                    patron pool-id executor executee collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_CollectableStakeFlow
                            patron executor executee pool-id collectable-id true nonces nonce-amounts true
                        )
                    )
                    (UC_FormatStakeCollectableResult
                        pool-id executor executee collectable-id true nonce-count
                    )
                )
            )
        )
    )
    (defun AQP-POOL|CC_UnstakeSemiFungibleCollectable:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            collectable-id:string
            nonces:[integer]
            nonce-amounts:[integer]
        )
        @doc "Unstake DPSF collectable (son=true) from the (owner, beneficiary) row. M5: executee caller-supplied \
            \ (self OR foreign) so the exact staked row is located — mirrors TF."
        (let
            (
                (nonce-count:integer (length nonces))
            )
            (with-capability
                (AQP|C>UNSTAKE-SEMI-FUNGIBLE-COLLECTABLE
                    patron pool-id executor executee collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_CollectableStakeFlow
                            patron executor executee pool-id collectable-id true nonces nonce-amounts false
                        )
                    )
                    (UC_FormatUnstakeCollectableResult pool-id executor collectable-id true nonce-count)
                )
            )
        )
    )
    (defun AQP-POOL|CC_StakeNonFungibleCollectable:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            collectable-id:string
            nonces:[integer]
        )
        @doc "Stake DPNF collectable (son=false). Poll DPDC::UR_AccountNoncesSupplies, then FVT::CC_CollectableStakeFlow."
        (let
            (
                (ref-DPDC:module{DpdcV3} DPDC)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[integer] (ref-DPDC::UR_AccountNoncesSupplies executor collectable-id false nonces))
            )
            (with-capability
                (AQP|C>STAKE-NON-FUNGIBLE-COLLECTABLE
                    patron pool-id executor executee collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_CollectableStakeFlow
                            patron executor executee pool-id collectable-id false nonces nonce-amounts true
                        )
                    )
                    (UC_FormatStakeCollectableResult
                        pool-id executor executee collectable-id false nonce-count
                    )
                )
            )
        )
    )
    (defun AQP-POOL|CC_UnstakeNonFungibleCollectable:string
        (
            patron:string
            executor:string
            executee:string
            pool-id:string
            collectable-id:string
            nonces:[integer]
            nonce-amounts:[integer]
        )
        @doc "Unstake DPNF collectable (son=false) from the (owner, beneficiary) row. M5: executee caller-supplied \
            \ (self OR foreign) so the exact staked row is located — mirrors TF."
        (let
            (
                (nonce-count:integer (length nonces))
            )
            (with-capability
                (AQP|C>UNSTAKE-NON-FUNGIBLE-COLLECTABLE
                    patron pool-id executor executee collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_CollectableStakeFlow
                            patron executor executee pool-id collectable-id false nonces nonce-amounts false
                        )
                    )
                    (UC_FormatUnstakeCollectableResult pool-id executor collectable-id false nonce-count)
                )
            )
        )
    )
    ;;
    ;; Vacate — Full (1 tx) or Stateless Legs (N txs; auto-begin; finalize on last)
    ;;
    (defun AQP-POOL|C_AbortVacate:string
        (patron:string executor:string pool-id:string)
        @doc "Clear vacate-in-progress; stake stays disabled. Talos → AQP-VCT::C_AbortVacate."
        (with-capability (AQP|C>ABORT-VACATE patron pool-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::C_AbortVacate patron executor pool-id)
                )
                (format "Successfully aborted vacate-in-progress on Pool {} (stake remains disabled)."
                    [pool-id]
                )
            )
        )
    )
    (defun AQP-POOL|A_FinalizeVacate:string
        (pool-id:string)
        @doc "Vacate-v2 FINALIZE (nuke) — after a pool has been fully drained via AQP-POOL|AAp_BatchDrain*, \
            \ this bulk-zeroes every employed score + bumps their vacate-generation (lazily invalidating all \
            \ per-user rows), then clears vacate-in-progress and unfreezes the pool's FVTs. \
            \ \
            \ IT DOES NOT RE-ENABLE STAKE. Owner ruling, 2026-10-30: the pool owner reopens deliberately with \
            \ AQP-POOL|C_EnablePoolStake once the score work is done. Every exit from a vacate campaign now \
            \ leaves the pool shut — the module used to disagree with itself, since the ABORT exit already \
            \ said 'stake stays disabled' while the SUCCESS exit sprang the pool open. \
            \ \
            \ ADMIN-ONLY, BECAUSE IT IS THE DRAIN'S TERMINAL STEP AND ONLY ADMINS DRAIN. v1 \
            \ CCp_BatchVacate* auto-finalizes, so a client-callable finaliser would be a door with no room \
            \ behind it. Same two gates as the drain batches: P|ADMINISTRATIVE-SUMMONER to be allowed at all, \
            \ and AQP-VCT's nns==0 + pool-owner-by-SIGNER check inside the cap. \
            \ \
            \ GASLESS MEANS NO IGNIS, NOT NO GAS — the Chainweb gas is still paid by the Ouronet gas station."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DALOS-G:module{OuronetDalosV3} DALOS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
                    (gasless:string (ref-DALOS-G::GOV|DALOS|SC_NAME))
                )
                (ref-IGNIS::XE_CollectIgnis gasless
                    (ref-VCT::C_FinalizeVacate gasless gasless pool-id))
                (format "Successfully finalized vacate on Pool {} — scores nuked. Stake stays DISABLED until the owner re-enables it. [gasless admin]"
                    [pool-id])
            )
        )
    )
    (defun AQP-POOL|CC_FullVacate:string
        (patron:string executor:string pool-id:string)
        @doc "Vacate rehaul — pool-owner AGNOSTIC full vacate (one tx): input is JUST the pool-id. VCT reads the \
            \ pool class + scans its inventory on-chain and vacates every asset type. Owner enforced in VCT|C>VACATE; \
            \ collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::CC_FullVacate patron executor pool-id))
                (format "Successfully full-vacated Pool {} (all asset types)." [pool-id])
            )
        )
    )
    (defun AQP-POOL|CCp_BatchVacateTrueFungible:string
        (patron:string pool-id:string dptf-id:string owner-ids:[string] beneficiary-ids:[string] amounts:[decimal])
        @doc "One TF batch of a UI-sliced vacate campaign. The first successful batch freezes the pool + its FVTs; \
            \ the batch that empties the pool auto-finalizes/unfreezes. Owner enforced in VCT; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::CCp_BatchVacateTrueFungible pool-id dptf-id owner-ids beneficiary-ids amounts))
                (format "Batch-vacated {} TF leg(s) on Pool {} (asset {})." [(length owner-ids) pool-id dptf-id])
            )
        )
    )
    (defun AQP-POOL|AAp_BatchDrainTrueFungible:string
        (pool-id:string dptf-id:string owner-ids:[string] beneficiary-ids:[string] amounts:[decimal])
        @doc "Vacate-v2 FAST-DRAIN — one TF batch that returns assets + preserves rewards WITHOUT touching \
            \ scores and WITHOUT finalizing (cheaper than CCp_BatchVacateTrueFungible for large pools). First \
            \ batch freezes the pool + its FVTs; the pool stays frozen until AQP-POOL|A_FinalizeVacate nukes \
            \ the scores once empty. \
            \ \
            \ ADMIN-ONLY SINCE 2026-10-30, and the client wrapper is GONE rather than demoted. Owner ruling: \
            \ the v1 CCp_BatchVacate* path updates the score in the SAME transaction that moves the assets, so \
            \ every leg is a complete event — 'user sees he got his assets and that the score properly \
            \ updated'. v2 moves the assets and DEFERS the score, which leaves the chain stating two things \
            \ that cannot both be true — trackers empty, holders still weighted — and it is commit-forward, so \
            \ there is no Abort to back out of that state. v2 is kept for observational comparison against v1, \
            \ not for clients. \
            \ \
            \ TWO GATES, BOTH REQUIRED. P|ADMINISTRATIVE-SUMMONER says the call may happen at all, and \
            \ AQP-VCT's CAP_VctVacatePoolOwner still requires the TX SENDER to own the pool — this family \
            \ authorises by SIGNER, not by an <executor> argument, which is why none is taken. The admin can \
            \ therefore drain only pools the administrator owns, exactly as the gasless eviction pair evicts \
            \ only FVTs it owns. \
            \ \
            \ GASLESS MEANS NO IGNIS, NOT NO GAS — the Chainweb gas is still paid by the Ouronet gas station, \
            \ because this is a Talos path."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DALOS-G:module{OuronetDalosV3} DALOS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
                    ;;THE GASLESS PATRON, RESOLVED LOCALLY -- the same source URC_Gassless reads, so the two
                    ;;cannot drift. `GASLESS-PATRON` is a defconst in 01_TS01-A, not in this module.
                    (gasless:string (ref-DALOS-G::GOV|DALOS|SC_NAME))
                )
                (ref-IGNIS::XE_CollectIgnis gasless
                    (ref-VCT::CCp_BatchDrainTrueFungible pool-id dptf-id owner-ids beneficiary-ids amounts))
                (format "Fast-drained {} TF leg(s) on Pool {} (asset {}) — scores untouched, awaiting finalize. [gasless admin]"
                    [(length owner-ids) pool-id dptf-id])
            )
        )
    )
    (defun AQP-POOL|AAp_BatchDrainOrtoFungible:string
        (pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]])
        @doc "Vacate-v2 FAST-DRAIN — one OF batch that returns nonces + preserves rewards WITHOUT touching \
            \ scores and WITHOUT finalizing. First batch freezes the pool + its FVTs; it stays frozen until \
            \ AQP-POOL|A_FinalizeVacate nukes the scores once empty. \
            \ \
            \ ADMIN-ONLY SINCE 2026-10-30, and the client wrapper is GONE rather than demoted. Owner ruling: \
            \ the v1 CCp_BatchVacate* path updates the score in the SAME transaction that moves the assets, so \
            \ every leg is a complete event — 'user sees he got his assets and that the score properly \
            \ updated'. v2 moves the assets and DEFERS the score, which leaves the chain stating two things \
            \ that cannot both be true — trackers empty, holders still weighted — and it is commit-forward, so \
            \ there is no Abort to back out of that state. v2 is kept for observational comparison against v1, \
            \ not for clients. \
            \ \
            \ TWO GATES, BOTH REQUIRED. P|ADMINISTRATIVE-SUMMONER says the call may happen at all, and \
            \ AQP-VCT's CAP_VctVacatePoolOwner still requires the TX SENDER to own the pool — this family \
            \ authorises by SIGNER, not by an <executor> argument, which is why none is taken. The admin can \
            \ therefore drain only pools the administrator owns, exactly as the gasless eviction pair evicts \
            \ only FVTs it owns. \
            \ \
            \ GASLESS MEANS NO IGNIS, NOT NO GAS — the Chainweb gas is still paid by the Ouronet gas station, \
            \ because this is a Talos path."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DALOS-G:module{OuronetDalosV3} DALOS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
                    ;;THE GASLESS PATRON, RESOLVED LOCALLY -- the same source URC_Gassless reads, so the two
                    ;;cannot drift. `GASLESS-PATRON` is a defconst in 01_TS01-A, not in this module.
                    (gasless:string (ref-DALOS-G::GOV|DALOS|SC_NAME))
                )
                (ref-IGNIS::XE_CollectIgnis gasless
                    (ref-VCT::CCp_BatchDrainOrtoFungible gasless pool-id dpof-id owner-ids beneficiary-ids nonces-array))
                (format "Fast-drained {} OF leg(s) on Pool {} (asset {}) — scores untouched, awaiting finalize. [gasless admin]"
                    [(length owner-ids) pool-id dpof-id])
            )
        )
    )
    (defun AQP-POOL|AAp_BatchDrainCollectable:string
        (pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]])
        @doc "Vacate-v2 FAST-DRAIN — one collectable batch (DPSF son=true / DPNF son=false) that returns \
            \ nonces + preserves rewards WITHOUT touching scores and WITHOUT finalizing. First batch freezes \
            \ the pool + its FVTs; it stays frozen until AQP-POOL|A_FinalizeVacate nukes the scores once \
            \ empty. \
            \ \
            \ ADMIN-ONLY SINCE 2026-10-30, and the client wrapper is GONE rather than demoted. Owner ruling: \
            \ the v1 CCp_BatchVacate* path updates the score in the SAME transaction that moves the assets, so \
            \ every leg is a complete event — 'user sees he got his assets and that the score properly \
            \ updated'. v2 moves the assets and DEFERS the score, which leaves the chain stating two things \
            \ that cannot both be true — trackers empty, holders still weighted — and it is commit-forward, so \
            \ there is no Abort to back out of that state. v2 is kept for observational comparison against v1, \
            \ not for clients. \
            \ \
            \ TWO GATES, BOTH REQUIRED. P|ADMINISTRATIVE-SUMMONER says the call may happen at all, and \
            \ AQP-VCT's CAP_VctVacatePoolOwner still requires the TX SENDER to own the pool — this family \
            \ authorises by SIGNER, not by an <executor> argument, which is why none is taken. The admin can \
            \ therefore drain only pools the administrator owns, exactly as the gasless eviction pair evicts \
            \ only FVTs it owns. \
            \ \
            \ GASLESS MEANS NO IGNIS, NOT NO GAS — the Chainweb gas is still paid by the Ouronet gas station, \
            \ because this is a Talos path."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DALOS-G:module{OuronetDalosV3} DALOS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
                    ;;THE GASLESS PATRON, RESOLVED LOCALLY -- the same source URC_Gassless reads, so the two
                    ;;cannot drift. `GASLESS-PATRON` is a defconst in 01_TS01-A, not in this module.
                    (gasless:string (ref-DALOS-G::GOV|DALOS|SC_NAME))
                )
                (ref-IGNIS::XE_CollectIgnis gasless
                    (ref-VCT::CCp_BatchDrainCollectable pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array))
                (format "Fast-drained {} collectable leg(s) on Pool {} (asset {}) — scores untouched, awaiting finalize. [gasless admin]"
                    [(length owner-ids) pool-id collectable-id])
            )
        )
    )
    (defun AQP-POOL|CCp_BatchVacateOrtoFungible:string
        (patron:string pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]])
        @doc "One OF batch of a UI-sliced vacate campaign (amounts resolved on-chain from the tracker). First batch \
            \ freezes; the emptying batch auto-finalizes/unfreezes. Owner enforced in VCT; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::CCp_BatchVacateOrtoFungible patron pool-id dpof-id owner-ids beneficiary-ids nonces-array))
                (format "Batch-vacated {} OF leg(s) on Pool {} (asset {})." [(length owner-ids) pool-id dpof-id])
            )
        )
    )
    (defun AQP-POOL|CCp_BatchVacateCollectables:string
        (patron:string pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]])
        @doc "One DPSF (son=true) / DPNF (son=false) batch of a UI-sliced vacate campaign. First batch freezes; the \
            \ emptying batch auto-finalizes/unfreezes. Owner enforced in VCT; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV4} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::CCp_BatchVacateCollectables pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array))
                (format "Batch-vacated {} collectable leg(s) on Pool {} (asset {}, son {})."
                    [(length owner-ids) pool-id collectable-id son])
            )
        )
    )
    (defun AQP-POOL|CC_UpdateScoreMultipliers:string
        (patron:string executor:string score-id:string
         mx-frozen:decimal mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Re-set a score's frozen/sleeping/hibernating multipliers. Talos shell → AQP-POOL::CC_UpdateScoreMultipliers. \
            \ Refused while a frozen or sleeping position exists on the score; the result string says \
            \ which rule a caller just satisfied, because `mx-sleeping` is a CEILING and reads like a \
            \ factor."
        ;;THE CAPABILITY IS ACQUIRED HERE, AND THAT IS WHAT MAKES THE CALL LEGAL. `P|UEV_IMC` on
        ;;the core client asks whether a registered inter-module guard is in scope; acquiring the
        ;;callee's own `AQP|C>...` from Talos is what puts one there. Calling the client directly
        ;;fails with "None of the guards passed" from `U|G::UEV_Any`, several frames below the
        ;;mistake -- which is exactly how this was found.
        (with-capability
            (AQP|C>UPDATE-SCORE-MULTIPLIERS patron executor score-id mx-frozen mx-sleeping mx-hibernated)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::CC_UpdateScoreMultipliers patron executor score-id mx-frozen mx-sleeping mx-hibernated)
                )
                (format "Score {} now frozen x{} (flat, a freeze is permanent), sleeping UP TO x{} (reached only at the full 25-year lock), hibernating x{} (flat, it asks no commitment)."
                    [score-id mx-frozen mx-sleeping mx-hibernated]
                )
            )
        )
    )
    (defun AQP-POOL|C_BeginScoreRevoke:string
        (patron:string executor:string pool-id:string score-id:string)
        @doc "PHASE 1 of 3 — begin retiring a score from a pool: vacate its slot and freeze the \
            \ pool. Pool owner. Talos shell → AQP-POOL::C_BeginScoreRevoke. \
            \ \
            \ Use this when `AQP-POOL|C_RevokeScore` refuses because holders still carry weight \
            \ for the score. Then drain with `AQP-POOL|Cp_DrainScoreSlice` until \
            \ `URHC_AQP|ScoreDrainOutstanding` is empty, finalize, and clear the freeze."
        ;;THE SLOT INDEX IS READ THROUGH THE MODREF, not by a dot call. `AQP-POOL.URC_...` would
        ;;have PINNED AQP-POOL's code hash at this module's deploy time, adding a permanent
        ;;(callee, caller) edge that forces Talos to redeploy with every AQP-POOL change -- and
        ;;a stale dot caller of a table-owning callee does not go quietly stale, it aborts with
        ;;"hash not blessed". `_dotpin.py --check` refused the first draft of this wrapper.
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
            )
            (with-capability (AQP|C>BEGIN-SCORE-REVOKE patron executor pool-id score-id
                                (ref-AQP::URC_ScoreSlotIndexForScore pool-id score-id))
                (do
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-AQP::C_BeginScoreRevoke patron executor pool-id score-id)
                    )
                    (format "Score {} unslotted from pool {}. Pool is FROZEN: drain its holders, finalize, then clear."
                        [score-id pool-id]
                    )
                )
            )
        )
    )
    (defun AQP-POOL|Cp_DrainScoreSlice:string
        (patron:string pool-id:string score-id:string accounts:[string])
        @doc "PHASE 2 of 3 — retire one SLICE of the holders of a score that is mid-revoke. Talos \
            \ shell → AQP-POOL::Cp_DrainScoreSlice. Permissionless and idempotent: send one per \
            \ slice of `URHC_AQP|ScoreDrainOutstanding`, in any order, in parallel, as often as you \
            \ like — an account already retired contributes a zero delta. Complete when that read \
            \ returns []."
        (with-capability (AQP|C>DRAIN-SCORE-SLICE patron pool-id score-id accounts)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::Cp_DrainScoreSlice patron pool-id score-id accounts)
                )
                (format "Retired {} holder(s) of score {} in pool {}. Drain is complete when URHC_AQP|ScoreDrainOutstanding returns []."
                    [(length accounts) score-id pool-id]
                )
            )
        )
    )
    (defun AQP-POOL|CC_FinalizeScoreRevoke:string
        (patron:string executor:string pool-id:string score-id:string)
        @doc "PHASE 3 of 3 — cut the score's aqpool-link now that no holder carries weight for it. \
            \ Pool owner. Talos shell → AQP-POOL::CC_FinalizeScoreRevoke. Refused while a single \
            \ holder remains. Does NOT release the pool freeze — `AQP-POOL|CC_ClearPoolSweep` does, \
            \ and only when every score on the pool is clear."
        (with-capability (AQP|C>FINALIZE-SCORE-REVOKE patron executor pool-id score-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::CC_FinalizeScoreRevoke patron executor pool-id score-id)
                )
                (format "Score {} fully retired from pool {}." [score-id pool-id])
            )
        )
    )
    (defun AQP-FVT|CC_ClearPoolSweep:string
        (patron:string pool-id:string)
        @doc "Release a pool's sweep freeze and return it to trading. Talos shell → \
            \ AQP-FVT::CC_ClearPoolSweep. PERMISSIONLESS and self-proving: it succeeds only when \
            \ every employed score is fully re-rated and no retired score still holds weight, so \
            \ anybody may be the one to finish the job — including a holder who wants to exit."
        (with-capability (FVT|C>CLEAR-POOL-SWEEP patron pool-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_ClearPoolSweep patron pool-id)
                )
                (format "Pool {} released: no outstanding re-rate or drain work remains." [pool-id])
            )
        )
    )
    (defun AQP-POOL|CCp_BackfillScoreSlice:string
        (patron:string pool-id:string score-id:string beneficiaries:[string])
        @doc "Re-rate one SLICE of a score's holders to their canonical base. Talos shell → \
            \ AQP-POOL::CCp_BackfillScoreSlice. Permissionless and idempotent: send one per slice \
            \ of `URHC_AQP|ScoreBackfillOutstanding`, in any order, in parallel, as many times as \
            \ you like — a holder already correctly rated contributes a zero delta. The sweep is \
            \ complete when that read returns []."
        (with-capability (AQP|C>BACKFILL-SCORE-SLICE patron pool-id score-id beneficiaries)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::CCp_BackfillScoreSlice patron pool-id score-id beneficiaries)
                )
                (format "Re-rated {} holder(s) of score {} in pool {}. The sweep is complete when URHC_AQP|ScoreBackfillOutstanding returns []."
                    [(length beneficiaries) score-id pool-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_SyncTrueFungibleAnchors:string
        (patron:string executee:string dptf-id:string)
        @doc "Pool-agnostic TF anchor repair for beneficiary × dptf-id. Talos shell → AQP-POOL::C_SyncTrueFungibleAnchors."
        (with-capability (AQP|C>SYNC-TF-ANCHORS patron executee dptf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_SyncTrueFungibleAnchors patron executee dptf-id)
                )
                (format "Successfully synced TrueFungible anchors for beneficiary {} on {}."
                    [(UC_ShortAccount executee) dptf-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_SyncSemiFungibleAnchors:string
        (patron:string executee:string dpsf-id:string)
        @doc "Pool-agnostic DPSF anchor repair. Talos shell → AQP-POOL::C_SyncCollectableAnchors son=true."
        (with-capability (AQP|C>SYNC-SEMI-FUNGIBLE-ANCHORS patron executee dpsf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_SyncCollectableAnchors patron executee dpsf-id true)
                )
                (format "Successfully synced SemiFungible anchors for beneficiary {} on {}."
                    [(UC_ShortAccount executee) dpsf-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_SyncNonFungibleAnchors:string
        (patron:string executee:string dpnf-id:string)
        @doc "Pool-agnostic DPNF anchor repair. Talos shell → AQP-POOL::C_SyncCollectableAnchors son=false."
        (with-capability (AQP|C>SYNC-NON-FUNGIBLE-ANCHORS patron executee dpnf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_SyncCollectableAnchors patron executee dpnf-id false)
                )
                (format "Successfully synced NonFungible anchors for beneficiary {} on {}."
                    [(UC_ShortAccount executee) dpnf-id]
                )
            )
        )
    )
    ;;
    ;; --- AQP-FVT lifecycle (Talos client shell → AQP-FVT::C_*) ---
    (defun AQP-FVT|C_Issue:string
        (patron:string executor:string fvt-name:string fvt-class:integer common-denominator:string)
        @doc "Issues an FVT (farm/vault/treasury) and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-FVT::C_Issue patron executor fvt-name fvt-class common-denominator)
                    )
                    (out:[string] (at "output" ico))
                    (fvt-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully issued FVT {} (class {})." [fvt-id fvt-class])
            )
        )
    )
    (defun AQP-FVT|C_IssueMultipletFamily:string
        (
            patron:string
            executor:string
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
        )
        @doc "Issues chain-wide MultipletFamily F|t0|t1|t2 (rank 3) with ATS ladder validation."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-FVT::C_IssueMultipletFamily
                            patron executor token-0-id token-1-id token-2-id ats-0-1-id ats-1-2-id
                        )
                    )
                    (out:[string] (at "output" ico))
                    (family-id:string (at 0 out))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully issued MultipletFamily {}." [family-id])
            )
        )
    )
    (defun AQP-FVT|C_AddScoreEntity:string
        (patron:string executor:string fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "Admits score (type 1) or triplet (type 3) to fvt-id via ScoreEntityLink."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_AddScoreEntity patron executor fvt-id score-entity-type score-entity-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully added score-entity type {} id {} to FVT {}."
                    [score-entity-type score-entity-id fvt-id]
                )
            )
        )
    )
    (defun AQP-FVT|C_AddRewardLink:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
        @doc "Registers one reward DPTF on fvt-id (multiplet-family-id BAR for plain tokens). Collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_AddRewardLink patron executor fvt-id reward-dptf-id segmentation multiplet-family-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully added reward link {} on FVT {} (family={})."
                    [reward-dptf-id fvt-id multiplet-family-id]
                )
            )
        )
    )
    (defun AQP-FVT|C_ToggleScoreEntityLink:string
        (patron:string executor:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
        @doc "Toggles ScoreEntityLink.enabled and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_ToggleScoreEntityLink patron executor fvt-id score-entity-type score-entity-id enabled)
                )
                (format "Successfully toggled score-entity type {} id {} on FVT {} to enabled={}."
                    [score-entity-type score-entity-id fvt-id enabled]
                )
            )
        )
    )
    (defun AQP-FVT|C_ToggleRewardLink:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Toggles reward-enabled and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_ToggleRewardLink patron executor fvt-id reward-dptf-id enabled)
                )
                (format "Successfully toggled reward link {} on FVT {} to enabled={}." [reward-dptf-id fvt-id enabled])
            )
        )
    )
    (defun AQP-FVT|C_SetMinInjectAmount:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string min-inject-amount:decimal)
        @doc "Sets one reward lane's MINIMUM single injection (owner-gated) and collects IGNIS on \
            \ patron. The floor exists because the stale-fix loop inside an inject runs regardless \
            \ of amount, so without it one smallest unit buys a full force-fix of the membership. \
            \ Every lane is created at the default, so this raises an existing floor rather than \
            \ introducing one."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_SetMinInjectAmount patron executor fvt-id reward-dptf-id min-inject-amount)
                )
                (format "Successfully set minimum injection on lane {} of FVT {} to {}." [reward-dptf-id fvt-id min-inject-amount])
            )
        )
    )
    (defun AQP-FVT|C_SetQualitySplit:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
        @doc "Round B: set a MULTIPLET_BASE reward's quality-split MODE + heterogeneous MATRIX (owner-gated). \
            \ HOMOGENEOUS routes each lane to its one ladder token; HETEROGENEOUS splits each lane across all 3 \
            \ ladder tokens per its [to-t0 to-t1 to-t2] per-mille row. Collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_SetQualitySplit patron executor fvt-id reward-dptf-id mode bronze-split silver-split gold-split)
                )
                (format "Successfully set quality split mode={} on reward {} of FVT {}." [mode reward-dptf-id fvt-id])
            )
        )
    )
    (defun AQP-FVT|C_Control:string
        (patron:string executor:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Updates FVT control flags and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_Control patron executor fvt-id new-can-upgrade new-can-change-owner)
                )
                (format "Successfully updated control flags for FVT {}." [fvt-id])
            )
        )
    )
    (defun AQP-FVT|C_RotateOwnership:string
        (patron:string executor:string executee:string fvt-id:string)
        @doc "Rotates FVT ownership and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_RotateOwnership patron executor executee fvt-id)
                )
                (format "Successfully rotated ownership for FVT {} to {}." [fvt-id executee])
            )
        )
    )
    (defun AQP-FVT|C_SetCommonDenominator:string
        (patron:string executor:string fvt-id:string common-denominator:string)
        @doc "Sets farm common-denominator (before ScoreEntityLinks) and collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_SetCommonDenominator patron executor fvt-id common-denominator)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully set common-denominator on FVT {} to {}." [fvt-id common-denominator])
            )
        )
    )
    (defun AQP-FVT|C_SetMosaic:string
        (patron:string executor:string fvt-id:string mosaic:bool)
        @doc "Sets mosaic membership policy when FVT has no member links; collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_SetMosaic patron executor fvt-id mosaic)
                )
                (format "Successfully set mosaic on FVT {} to {}." [fvt-id mosaic])
            )
        )
    )
    (defun AQP-FVT|C_SetSplitMode:string
        (patron:string executor:string fvt-id:string split-mode:string)
        @doc "Sets a farm's reward-split mode (SPLIT|STAKED participation | SPLIT|TVL pool-size); collects IGNIS on patron. \
            \ Freely mutable — re-weights only future injects."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_SetSplitMode patron executor fvt-id split-mode)
                )
                (format "Successfully set reward-split mode on farm {} to {}." [fvt-id split-mode])
            )
        )
    )
    (defun AQP-FVT|C_IssueGenericEarningVault:string
        (patron:string executor:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
        @doc "Stand up a complete single-asset earning Vault in ONE transaction and ONE IGNIS \
            \ collection: stake a true fungible, earn another true fungible. Composes the six core \
            \ operations a Vault needs and concatenates their cumulators, so the caller pays once \
            \ rather than six times."
        ;; WHY THIS IS A TALOS ORCHESTRATOR AND NOT A CITIZEN HELPER
        ;;   The same six steps written in a citizen module would call the six TS02-C3 wrappers,
        ;;   and EVERY ONE OF THOSE COLLECTS IGNIS ON ITS OWN -- six collections for one logical
        ;;   operation. Composing the CORE C_ functions here and concatenating their cumulators
        ;;   collects once, which is the entire reason this belongs in Talos.
        ;;
        ;; WHAT A VAULT ACTUALLY NEEDS -- six operations, four class constants
        ;;   1 score for the staked DPTF   score-class 1
        ;;   2 pool it is staked into      aqp-class 1   (0 is reserved for LP)
        ;;   3 score -> pool link          without it the pool scores nothing
        ;;   4 the FVT entity              fvt-class 1 (Vault)
        ;;   5 score admitted to the FVT   score-entity type 1
        ;;   6 reward token registered     multiplet-family-id BAR (plain, not a laddered family)
        ;;
        ;;   Step 6 is not optional: an EMPLOYED score with no reward link makes every stake abort
        ;;   in the FVT pipeline (05_FVT.pact:1210). Doing 1-5 without 6 builds a vault nobody can
        ;;   use, which is a state this function makes unreachable.
        ;;
        ;; CLASS SAFETY
        ;;   Two sovereign admission rules disagree about fvt-class for SF/NF
        ;;   (URC_ScoreClassMatchesFvtClass vs URC_TripletCategoryMatchesFvtClass). They AGREE for
        ;;   true fungibles: score-class 1 is admitted at fvt-class 1 by the first, and VAULT_TF
        ;;   maps to 1 in the second. A TF-in/TF-out vault is the case both describe identically,
        ;;   so this function does not depend on how that dispute is settled.
        ;;
        ;; NAMING -- one name in, three derived, and they MUST differ
        ;;   UDC_Makeid is <name>-<block-hash> and ids collide across families because
        ;;   BRD|BrandingTable is shared (DPDC audit #33M). Three entities minted from one name in
        ;;   one transaction would produce three byte-identical ids and the second insert would
        ;;   hard-abort. Hence <name>Score / <name>Pool / <name>Vault.
        (with-capability (P|TS)
            (let*
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV3} AQP-POOL)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    ;;
                    (score-name:string (concat [vault-name "Score"]))
                    (pool-name:string (concat [vault-name "Pool"]))
                    (fvt-name:string (concat [vault-name "Vault"]))
                    ;;ids are derived in THIS transaction for entities minted in THIS transaction,
                    ;;so UDC_Makeid returns exactly what the C_Issue calls below are about to make.
                    (score-id:string (ref-U|DALOS::UDC_Makeid score-name))
                    (pool-id:string (ref-U|DALOS::UDC_Makeid pool-name))
                    (fvt-id:string (ref-U|DALOS::UDC_Makeid fvt-name))
                    ;;The POOL's executor is the STAKED ASSET's owner konto -- which is NOT
                    ;;necessarily `executor`, the account that will own the score and vault.
                    ;;A vault operator may stake a token somebody else issued. Derived, not assumed.
                    (stake-asset-owner:string
                        (ref-AQP::URC_AqpOwnerKontoFromClassAndAsset GV|POOL_CLASS_TF stake-dptf-id))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (ref-SCR::C_IssueTrueFungibleScore
                                patron executor score-name GV|PRECISION GV|MX_FROZEN)
                            (ref-AQP::C_Issue patron stake-asset-owner pool-name stake-dptf-id GV|POOL_CLASS_TF)
                            (ref-AQP::C_AddScore patron stake-asset-owner pool-id score-id)
                            (ref-FVT::C_Issue
                                patron executor fvt-name GV|FVT_CLASS_VAULT GV|COMMON_BAR)
                            ;;The FVT's executor here IS `executor` -- C_Issue two lines up
                            ;;makes that account the vault's owner, so it is derived, not assumed.
                            (ref-FVT::C_AddScoreEntity
                                patron executor fvt-id GV|SCORE_ENTITY_SCORE score-id)
                            (ref-FVT::C_AddRewardLink
                                patron executor fvt-id reward-dptf-id false GV|COMMON_BAR)
                        ]
                        []
                    )
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format
                    "Successfully issued Generic Earning Vault {}: stake {} earn {}. score={} pool={} fvt={}."
                    [vault-name stake-dptf-id reward-dptf-id score-id pool-id fvt-id]
                )
            )
        )
    )

    (defun AQP-FVT|CC_InjectStream:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
        @doc "Injects reward DPTF as a TIME-STREAM (linear vesting over `duration` seconds, 1h..365d) into fvt-id \
            \ and collects IGNIS on patron. The DELAYED counterpart of AQP-FVT|CC_Inject (instant): the amount vests \
            \ continuously and whoever is staked during each slice earns it (late stakers included). Independent \
            \ overlapping streams, capped by the FVT owner konto's Elite tier. See Audit/STREAMED-INJECT-DESIGN.md."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_InjectStream patron executor fvt-id reward-dptf-id amount duration)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully streamed {} {} into FVT {} over {}s." [amount reward-dptf-id fvt-id duration])
            )
        )
    )
    (defun AQP-FVT|CC_Inject:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "HEAVY enforced-FRESH inject for ANY FVT class (farm/vault/treasury; M3 #12): refreshes every stale \
            \ staker's deb so the divisor is live before injecting, then injects + collects IGNIS on patron. Same \
            \ shape as C_Inject. Farms are covered too — a mosaic farm's singular/non-true-triplet members are \
            \ deb-stale-exposed via SCR|ScoreTotalDebScore just like a vault."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_Inject patron executor fvt-id reward-dptf-id amount)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully FRESH-injected {} {} into FVT {}." [amount reward-dptf-id fvt-id])
            )
        )
    )
    (defun AQP-FVT|CCp_FvtFixSlice:string
        (patron:string fvt-id:string reward-dptf-id:string users:[string])
        @doc "PARALLEL fed slice of the enforced-fresh inject's fix phase: refresh exactly the \
            \ LISTED stale stakers. Read `URH_FvtStalePresentUsers`, split it into DISJOINT slices, \
            \ and send them together -- then `AQP-FVT|CC_InjectFinalize`. \
            \ \
            \ PREFER THIS OVER `AQP-FVT|CCp_InjectFixChunk` WHEN FANNING OUT. That one takes a \
            \ chunk SIZE and takes the first N of the shared stale list, so two concurrent sends \
            \ pick the SAME users -- duplicate work, and the 2e forced-fix penalty recorded twice \
            \ against those holders. This one takes the accounts, and re-checks staleness inside \
            \ the transaction, so an overlapping or replayed slice simply finds them fresh and \
            \ skips them with no second penalty. \
            \ \
            \ WHEN A SLICE IS NEEDED: adding or revoking a score entity on an FVT makes its \
            \ members deb-stale. That does NOT block stake or unstake -- a stale member mis-states \
            \ reward SHARES, never the base -- but `CC_InjectFinalize` refuses to inject while any \
            \ stale member remains, so the work has to be done before the next reward injection. \
            \ Lives in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-FVT::CCp_FvtFixSlice patron fvt-id reward-dptf-id users))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
            )
        )
    )
    (defun AQP-FVT|CCp_InjectFixChunk:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "PAGE the enforced-fresh inject's fix phase — refresh up to `chunk` currently-stale stakers (penalized), \
            \ the scalable prelude to AQP-FVT|CC_InjectFinalize for stale sets exceeding one tx. Repeat until none \
            \ remain. `chunk` is the UI's simulated slice (bounded by AQP-FVT's loose INJECT-FIX-CHUNK-MAX). Lives \
            \ in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-FVT::CCp_InjectFixChunk patron fvt-id reward-dptf-id chunk))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
            )
        )
    )
    (defun AQP-FVT|CC_InjectFinalize:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "FINALIZE a paginated enforced-fresh inject: after CCp_InjectFixChunk pages left ZERO stale, inject on \
            \ the fresh divisor + collect IGNIS on patron — same outcome as the single-tx AQP-FVT|CC_Inject. Lives \
            \ in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_InjectFinalize patron executor fvt-id reward-dptf-id amount)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully FRESH-injected {} {} into FVT {} (paginated)." [amount reward-dptf-id fvt-id])
            )
        )
    )
    (defun AQP-FVT|CCp_UnstaleAll:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "OWNER mass deb-unstale — force-refresh up to `chunk` currently-stale present stakers (penalized, same \
            \ 2e tag as an inject's fix) to make the FVT INJECTION-READY, WITHOUT injecting. Repeat until the report \
            \ says injection-ready (or `all up to date` when nothing is stale), then run a light AQP-FVT|CC_Inject. \
            \ Owner-gated in AQP-FVT::CCp_UnstaleAll. `chunk` is the UI's simulated slice (bounded by INJECT-FIX-CHUNK-MAX). \
            \ Lives in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-FVT::CCp_UnstaleAll patron fvt-id reward-dptf-id chunk))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
            )
        )
    )
    (defun MTX-AQP|2|CC_Inject:string
        (patron:string executor:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Starts the 2-step enforced-fresh inject defpact (MTX-AQP — spike fallback for AQP-FVT|CC_Inject when \
            \ the stale set exceeds one tx). Step 0 runs here; advance with (continue-pact 1). Each defpact step \
            \ collects its own IGNIS on patron, so this wrapper only summons the pact."
        (with-capability (P|TS)
            (let
                (
                    (ref-MTX-AQP:module{AqpMtxV2} MTX-AQP)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-MTX-AQP::C_2|Inject patron executor fvt-id reward-dptf-id amount))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
            )
        )
    )
    (defun MTX-AQP|2|CC_SweepRevokeAnchor:string
        (patron:string executor:string anchor-id:string)
        @doc "Starts the 2-step paginated re-score SWEEP defpact (MTX-AQP — spike fallback for \
            \ AQP-FVT|CC_SweepRevokeAnchor when the recompute set exceeds one tx). Step 0 brackets (freeze + \
            \ swept-revoke) + recomputes the first window here; advance with (continue-pact 1). The defpact is \
            \ gas-only (no reward inject), so this wrapper just summons the pact and refuels."
        (with-capability (P|TS)
            (let
                (
                    (ref-MTX-AQP:module{AqpMtxV2} MTX-AQP)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-MTX-AQP::C_2|SweepRevokeAnchor patron executor anchor-id))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
            )
        )
    )
    (defun AQP-FVT|CC_SweepRevokeAnchor:string
        (patron:string executor:string anchor-id:string)
        @doc "Single-tx re-score SWEEP that retires an EMPLOYED anchor (H4 half-2): freezes the affected pools, \
            \ removes the anchor (swept-revoke), recomputes every affected holder (aggregate/lane refold + deb), \
            \ then unfreezes. Owner-initiated (patron = the anchored-asset owner). Lives in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-FVT::CC_SweepRevokeAnchor patron executor anchor-id))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
            )
        )
    )
    (defun AQP-FVT|CC_SweepBegin:string
        (patron:string executor:string anchor-id:string)
        @doc "OPEN a paginated (defun+gate) re-score sweep — the scalable twin of AQP-FVT|CC_SweepRevokeAnchor for \
            \ holder sets exceeding one tx: freezes the affected pools + swept-revokes the anchor, then defers the \
            \ recompute to AQP-FVT|CCp_SweepRecomputeChunk calls under the held freeze. Owner-initiated. Lives in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-FVT::CC_SweepBegin patron executor anchor-id))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
            )
        )
    )
    (defun AQP-FVT|CCp_SweepRecomputeChunk:string
        (patron:string anchor-id:string chunk:integer)
        @doc "PAGE an open re-score sweep: recompute the next `chunk` holders over the frozen global present set, \
            \ advancing the cursor; the finalizing chunk (set exhausted) unfreezes the affected pools. `chunk` is \
            \ the UI's simulated slice size (bounded by AQP-FVT's loose SWEEP-CHUNK-MAX backstop). Lives in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (let
                    (
                        (r:string (ref-FVT::CCp_SweepRecomputeChunk patron anchor-id chunk))
                    )
                    (ref-TS01-A::XB_DynamicFuelSTOA)
                    r
                )
            )
        )
    )
    (defun AQP-FVT|CC_UnstaleMyScores:string
        (patron:string executor:string fvt-ids:[string])
        @doc "User self-service deb-unstale: the caller refreshes THEIR OWN stale scores across the listed FVTs \
            \ (non-penalized — the cheap alternative to being force-fixed by an inject), then collects IGNIS on \
            \ patron. The UI finds the FVT list via RPS.URC_FvtUserHasStaleMember per FVT the user stakes. \
            \ Lives in AQP-FVT."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_UnstaleMyScores patron executor fvt-ids)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Refreshed your stale scores across {} FVT(s)." [(length fvt-ids)])
            )
        )
    )
    (defun AQP-FVT|CC_Collect:string
        (patron:string executor:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Collects pending reward DPTF for the EXECUTOR on one score-entity from fvt-id; collects IGNIS on \
            \ patron. \
            \ \
            \ THE @doc SAID \"for patron\" UNTIL 2026-10-29 AND THE BALANCE DIFF BELOW BELIEVED IT. \
            \ <FVT::CC_Collect> credits the EXECUTOR -- `XI_TransferRewardDptfFromVault`'s own doc calls it \
            \ the REWARD SUBJECT and says `patron` \"only pays IGNIS and is deliberately unused here\". So a \
            \ sponsored collect measured the SPONSOR's balance across a transfer that moved nothing of theirs \
            \ and reported `0.0` for a collect that really paid out. Reading the executor is the fix; the \
            \ figure is unchanged for a self-collect, where the two accounts are the same. \
            \ \
            \ IT STILL UNDERSTATES A TRIPLET LANE, and that is pre-existing rather than introduced here: a \
            \ MULTIPLET_BASE triplet pays in up to THREE tokens and this reads only <reward-dptf-id>, so the \
            \ coiled and double-coiled shares are invisible to it. <RPS::URC_CollectLadderPreview> is the \
            \ reader that answers per-token and exists for exactly that reason."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                    (bal-before:decimal (ref-DPTF::UR_AccountSupply reward-dptf-id executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_Collect patron executor fvt-id score-entity-type score-entity-id reward-dptf-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (let
                    (
                        (bal-after:decimal (ref-DPTF::UR_AccountSupply reward-dptf-id executor))
                        (payout:decimal (- bal-after bal-before))
                    )
                    (format "Successfully collected {} {} rewards from FVT {} for score-entity type {} id {}."
                        [payout reward-dptf-id fvt-id score-entity-type score-entity-id]
                    )
                )
            )
        )
    )
    ;;
    ;;  [AQP-EVCT -- Reward Eviction]
    ;;
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-EVCT|CCp_EvictMultiRewards:string
        (patron:string executor:string fvt-id:string beneficiaries:[string]
         score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string])
        @doc "ONE EVICTION SLICE: the FVT owner collects on behalf of the listed stakers, so each one \
            \ receives exactly what a self-collect would have paid them -- AQP-FVT's eviction surface \
            \ runs the SAME phase functions (XI_CollectDrip/XI_CollectPay) that CC_Collect runs. Owner \
            \ enforced in EVCT|C>EVICT-SLICE; IGNIS on patron. \
            \ \
            \ FED SLICE, SO PARALLEL-SAFE: the client dirty-reads AQP-EVCT::URHC_BuildEvictSlicePlan, \
            \ splits into disjoint gas-bounded slices and fires them at once. Contrast a cursor pager, \
            \ which is strictly sequential. \
            \ \
            \ WHAT IT DOES NOT DO: it does not touch scores (eviction only moves reward tokens, and \
            \ stale scores are refreshed exactly as a collect refreshes them), and it does not freeze \
            \ the FVT -- an eviction is a collect triggered by the pool owner instead of the \
            \ beneficiary, so there is nothing to protect from a concurrent stake."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-EVCT:module{AcquisitionRewardEvictionV1} AQP-EVCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-EVCT::CCp_EvictMultiRewards patron executor fvt-id beneficiaries
                        score-entity-types score-entity-ids reward-dptf-ids))
                (format "Evicted {} reward leg(s) on FVT {} to their beneficiaries."
                    [(length beneficiaries) fvt-id])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|ADMINISTRATIVE-SUMMONER
    (defun AQP-EVCT|AAp_EvictMultiRewards:string
        (executor:string fvt-id:string beneficiaries:[string]
         score-entity-types:[integer] score-entity-ids:[string] reward-dptf-ids:[string])
        @doc "GASLESS ADMIN eviction slice -- byte-for-byte AQP-EVCT|CCp_EvictMultiRewards with the Ouronet \
            \ system account in the patron slot, so no IGNIS is charged for it. \
            \ \
            \ FOR THE DAILY AUTOMATON. Owner, 2026-10-29: daily evictions across the FVTs the Ouronet \
            \ administrator owns would cost 'a ton of ignis', and the gasless patron is the only way \
            \ to make them sustainable. This wrapper IS that path, which is why no secondary \
            \ orchestration from the DSP module is needed to reach it. \
            \ \
            \ TWO GATES, BOTH REQUIRED: the ADMIN keyset (P|ADMINISTRATIVE-SUMMONER) says the call may \
            \ happen at all, and AQP-EVCT still requires <executor> to own <fvt-id>. Dropping the \
            \ first would make every FVT owner a free rider on the gas station; dropping the second \
            \ would let the administrator evict a stranger's FVT. \
            \ \
            \ GASLESS MEANS NO IGNIS, NOT NO GAS -- the Chainweb gas is still paid, by the Ouronet gas \
            \ station, because this is a Talos path."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DALOS-G:module{OuronetDalosV3} DALOS)
                    (ref-EVCT:module{AcquisitionRewardEvictionV1} AQP-EVCT)
                    ;;THE GASLESS PATRON, RESOLVED LOCALLY. `GASLESS-PATRON` is a defconst in
                    ;;01_TS01-A, not something every Talos module has, and the bare name reads as a
                    ;;MODULE reference to Pact. Read from the same source URC_Gassless reads: one
                    ;;definition, no chance of the two drifting.
                    (gasless:string (ref-DALOS-G::GOV|DALOS|SC_NAME))
                )
                (ref-IGNIS::XE_CollectIgnis gasless
                    (ref-EVCT::CCp_EvictMultiRewards gasless executor fvt-id beneficiaries
                        score-entity-types score-entity-ids reward-dptf-ids))
                (format "Evicted {} reward leg(s) on FVT {} to their beneficiaries. [gasless admin]"
                    [(length beneficiaries) fvt-id])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-EVCT|CC_EvictSingleReward:string
        (patron:string executor:string fvt-id:string beneficiary:string
         score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "ONE LEG, ONE TRANSACTION — the shape a large FVT is evicted with, and the one the UI \
            \ falls back to when AQP-EVCT|CC_FullEvictRewards does not fit. Owner enforced in \
            \ EVCT|C>EVICT-SINGLE; IGNIS on patron. \
            \ \
            \ THE TRANSACTION COUNT IS THE LEG COUNT. AQP-EVCT::URHC_BuildEvictPlans returns exactly \
            \ one object per leg, so a client sends one of these per entry and nothing has to be \
            \ packed, measured or resized. Owner, 2026-10-30: 'you can see instantly if there are 120 \
            \ tx constructed there are 120 legs.' \
            \ \
            \ SAFE BY CONSTRUCTION, not by measurement: one leg is one drip plus one pay, so no \
            \ single transaction in the campaign can approach the 2,000,000 ceiling. Contrast \
            \ AQP-EVCT|CCp_EvictMultiRewards, which must be measured against it and re-measured when \
            \ the data moves. \
            \ \
            \ ORDER-INDEPENDENT EXCEPT FOR THE DUST: the last claimant on a lane sweeps the \
            \ remainder, so whichever transaction lands last on a lane receives it. The lane still \
            \ ends at zero. A leg already collected refuses and moves nothing, so a fan-out must \
            \ expect some to bounce."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-EVCT:module{AcquisitionRewardEvictionV1} AQP-EVCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-EVCT::CC_EvictSingleReward patron executor fvt-id beneficiary
                        score-entity-type score-entity-id reward-dptf-id))
                (format "Evicted {} on FVT {} to {}." [reward-dptf-id fvt-id beneficiary])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|ADMINISTRATIVE-SUMMONER
    (defun AQP-EVCT|AA_EvictSingleReward:string
        (executor:string fvt-id:string beneficiary:string
         score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "GASLESS ADMIN single-leg eviction — byte-for-byte AQP-EVCT|CC_EvictSingleReward with the \
            \ Ouronet system account in the patron slot, so no IGNIS is charged. \
            \ \
            \ THIS IS THE AUTOMATON'S WORKHORSE. A daily eviction across the administrator's FVTs is \
            \ a fan-out of these: the count is known from the plan before anything is sent, every \
            \ transaction is the same size, and none of them can be refused for gas. See \
            \ AQP-EVCT|AAp_EvictMultiRewards for why the pair is admin-gated as well as owner-gated."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DALOS-G:module{OuronetDalosV3} DALOS)
                    (ref-EVCT:module{AcquisitionRewardEvictionV1} AQP-EVCT)
                    (gasless:string (ref-DALOS-G::GOV|DALOS|SC_NAME))
                )
                (ref-IGNIS::XE_CollectIgnis gasless
                    (ref-EVCT::CC_EvictSingleReward gasless executor fvt-id beneficiary
                        score-entity-type score-entity-id reward-dptf-id))
                (format "Evicted {} on FVT {} to {}. [gasless admin]"
                    [reward-dptf-id fvt-id beneficiary])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-EVCT|CC_FullEvictRewards:string (patron:string executor:string fvt-id:string)
        @doc "WHOLE-FVT eviction in ONE transaction -- the convenience path for a small FVT, which scans \
            \ its own legs instead of being handed a slice. A large FVT must use \
            \ AQP-EVCT|CCp_EvictMultiRewards: the node gas meter is the real ceiling and this scans before \
            \ it pays. Owner enforced in EVCT|C>FULL-EVICT; IGNIS on patron. \
            \ \
            \ Stands to AQP-EVCT|CCp_EvictMultiRewards exactly as AQP-POOL|CC_FullVacate stands to the \
            \ AQP-POOL|CCp_Batch* family."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-EVCT:module{AcquisitionRewardEvictionV1} AQP-EVCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-EVCT::CC_FullEvictRewards patron executor fvt-id))
                (format "Evicted every outstanding reward leg on FVT {} to its beneficiaries." [fvt-id])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|ADMINISTRATIVE-SUMMONER
    (defun AQP-EVCT|AA_FullEvictRewards:string (executor:string fvt-id:string)
        @doc "GASLESS ADMIN whole-FVT eviction. See AQP-EVCT|AAp_EvictMultiRewards for why the patron slot \
            \ carries the Ouronet system account, and why the executor is STILL owner-gated on top of \
            \ the admin keyset."
        (with-capability (P|ADMINISTRATIVE-SUMMONER)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DALOS-G:module{OuronetDalosV3} DALOS)
                    (ref-EVCT:module{AcquisitionRewardEvictionV1} AQP-EVCT)
                    (gasless:string (ref-DALOS-G::GOV|DALOS|SC_NAME))
                )
                (ref-IGNIS::XE_CollectIgnis gasless
                    (ref-EVCT::CC_FullEvictRewards gasless executor fvt-id))
                (format "Evicted every outstanding reward leg on FVT {} to its beneficiaries. [gasless admin]"
                    [fvt-id])
            )
        )
    )
    (defun AQP-DSA|CC_OpenAgency:string
        (patron:string executor:string fvt-id:string pool-id:string score-entity-id:string fee-per-mille:integer
         collectable-id:string stake-nonces:[integer])
        @doc "DSA (Talos): open a delegation agency ATOMICALLY under P|TS — (1) admit the operator's BLANK triplet \
            \ <score-entity-id> to vault <fvt-id> (AQP-DSA::C_AdmitAgency); (2) stake the operator's initial \
            \ <collectable-id>/<stake-nonces> from <pool-id> (FVT::CC_CollectableStakeFlow — runs under P|TS so the \
            \ deep DPDC custody transfer's IMC passes); (3) enforce the terminal quintessence >= unit-score/2 open \
            \ gate (AQP-DSA::UEV_OpenGate — a short stake reverts the whole open). Collects both cumulators on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPDC:module{DpdcV3} DPDC)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV5} AQP-FVT)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                )
                ;; (1) admit the blank triplet (fvt-links must be BAR) + record the agency
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DSA::C_AdmitAgency patron executor fvt-id score-entity-id fee-per-mille))
                ;; (2) stake the operator's initial quintessence into the now-linked, reward-ready triplet
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_CollectableStakeFlow
                        patron executor executor pool-id collectable-id true
                        stake-nonces (ref-DPDC::UR_AccountNoncesSupplies executor collectable-id true stake-nonces) true))
                ;; (3) terminal atomic gate — after the stake, Q must clear unit-score/2 or the whole tx reverts
                (ref-DSA::UEV_OpenGate fvt-id score-entity-id)
                (format "Agency opened on FVT {} for score-entity {} (fee {} per-mille)." [fvt-id score-entity-id fee-per-mille])
            )
        )
    )
    (defun AQP-DSA|C_RecomputeCapture:string
        (patron:string fvt-id:string score-entity-id:string)
        @doc "DSA (Talos): permissionlessly recompute an agency's capture from its current quintessence (after a \
            \ delegator stake/unstake changed Q); collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DSA:module{DsaV3} AQP-DSA)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DSA::C_RecomputeCapture patron fvt-id score-entity-id)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Capture recomputed for agency {} on FVT {}." [score-entity-id fvt-id])
            )
        )
    )
)

;; --- tables for 04_TS02-C3.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 2_CITIZEN/5_VaultsMinter/04_AQP-BOOT.pact ===================
;; AQP-BOOT — live-chain AQP provisioning helpers.
;; Purpose: one-shot bootstrap writers for score/anchor/pool/fvt infra.
;;
;; HANDOFF PATTERN (mainnet + REPL)
;;   • Each C_StepN_* is intended as its own transaction (or REPL begin-tx block).
;;   • Functions that CREATE entities echo ids in a formatted return string — copy these
;;     into the NEXT step's arguments when steps run on separate txs.
;;   • Functions that WIRE existing entities take explicit id lists (Step 7) so mainnet
;;     ids from prior txs are passed in; REPL uses the same shape with REPL chain ids.
;;   • UDC_Makeid("<Name>") is NOT deterministic from the name alone.
;;     CORRECTED 2026-09-18 -- this line used to read "ids are deterministic from names", and
;;     that is wrong in the dangerous direction. `UDC_Makeid ticker` returns
;;     `<ticker>-<first 12 chars of prev-block-hash>`, so the SAME ticker in a DIFFERENT BLOCK
;;     yields a DIFFERENT id.
;;     THE REPL CANNOT SHOW THIS: the whole suite runs under one `prev-block-hash`, so all 194
;;     fixture ids share a single suffix and recomputing an id in a later tx always matches.
;;     On mainnet, where every transaction is in its own block, it never will.
;;     CONSEQUENCE FOR DEPLOYMENT: an id for an entity created in an EARLIER transaction must be
;;     CARRIED FORWARD from that transaction's output string. Recomputing it with UDC_Makeid is
;;     a silent mis-wiring that no test in this repository can catch. Recomputing is only safe
;;     for an entity created in the SAME transaction (which is why Step 7's pool ids are fine
;;     but its score ids, from Steps 4-6, are arguments).
;;   • Collection asset ids (DHCD-…, DHB-…, OURO-…, LP native ids) are ALWAYS inputs —
;;     never embedded in code; REPL examples live in ;; blocks only.
;;   • Full step chain table: 2_CITIZEN/Stage_02/README_AQP_BOOT.md
;;   • OURO LP user flow: 1_SOVEREIGN/STAGE_02/2_Core/03_AQP/README.md § OURO LP onboarding
;;
;; STEP ORDER: 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12
;;   Step 0 — after sovereign AQP modules (ANK, SCR, AQP-POOL, FVT) are deployed: IMC + vault governor.
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
;; AcquisitionPoolBootV2: already deployed and unchanged -- see LIVE_INTERFACES


(module AQP-BOOT GOV






    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements AcquisitionPoolBootV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_AQP-BOOT                           (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|AQP_BOOT_ADMIN)))
    (defcap GOV|AQP_BOOT_ADMIN ()                       (enforce-guard GOV|MD_AQP-BOOT))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst BOOT|SCORE_SILVER:string                  "SilverSnakePower")
    (defconst BOOT|SCORE_BRONZE:string                  "BronzeSnakePower")
    (defconst BOOT|SCORE_GOLDEN:string                  "GoldenSnakePower")
    (defconst BOOT|PRECISION:integer                    6)
    ;;THE CANONICAL DEFAULTS, 2026-10-10. These were 2.0 / 2.0, and that pair is now ILLEGAL on
    ;;both of the rules AQP-SCORE enforces: a sleeping interval of 1.0 does not divide by three
    ;;(`UC_MxSleepIntervalOk`), and 2.0 frozen is below the 3.0 floor that a 2.0 ceiling demands
    ;;(`UC_MxOrderingOk`). Boot produced the only three LP scores on mainnet -- Bronze, Silver and
    ;;Golden SnakePower all carry 2.0/2.0 because of these two lines -- so this is where the wrong
    ;;numbers came from, and changing them here is what stops the next boot reintroducing them.
    ;;Deliberately NOT a reference to AQP-SCORE's CT_MX_* constants: AQP-BOOT is a CITIZEN module
    ;;and reaching into a sovereign module's constants for a value it passes as an ARGUMENT would
    ;;couple a boot script to an internal it does not own.
    (defconst BOOT|MX_FROZEN:decimal                    2.998)
    (defconst BOOT|MX_SLEEPING:decimal                  1.999)
    (defconst BOOT|FVT_OURO_LP_FARM:string              "OuroLpFarm")
    (defconst BOOT|FVT_SUBSIDIARY_TREASURY:string       "SubsidiaryTreasury")
    (defconst BOOT|FVT_CODING_TREASURY:string           "CodingDivisionTreasury")
    (defconst BOOT|FVT_SNAKES_TREASURY:string           "SnakesTreasury")
    (defconst BOOT|FVT_SHARES_TREASURY:string           "CompanySharesTreasury")
    ;;ADDED 2026-09-19. The fifth treasury. C_Step4 creates FOUR core scores and three of them
    ;;had a treasury of their own -- TheCodingDivision, DemiourgosSnakes, DemiourgosShareholder --
    ;;while `Bloodshed` had none, even though C_Step7 attaches it to DHBloodshed and so makes it
    ;;EMPLOYED. An employed score with no FVT link and no reward DPTF aborts every stake at
    ;;05_FVT.pact:1031. Owner ruling 2026-09-19: "staking bloodshed assets determines the pure
    ;;bloodshed score, and we need to be able to earn stuff via that score alone" -- so it earns,
    ;;and it earns through its own class-2 Treasury (the score is NF, and treasuries take SF/NF).
    (defconst BOOT|FVT_BLOODSHED_TREASURY:string "BloodshedTreasury")
    ;;THE THREE LATE ENTITIES, added 2026-10-08. Steps 8/9/12 were written when the boot ladder
    ;;owned every score it wired. Three scores exist that it does not:
    ;;
    ;;  NosferatuDracula  class 4 (DPNF)  pool DHNosferatu     -- issued from the UI
    ;;  WonderCoach       class 3 (DPSF)  pool DHWonderCoach   -- issued from the UI
    ;;  StoicPower        class 1 (DPTF)  pool NONE            -- issued from the UI
    ;;
    ;;Step 7 already attaches the first two to their pools (dh-score-ids[9..10]); what it has
    ;;never had is an FVT for either, so Step 9 could not admit them and their pools would stay
    ;;unstakeable however many aggregators existed. StoicPower has neither pool nor FVT.
    (defconst BOOT|FVT_NOSFERATU_TREASURY:string        "NosferatuTreasury")
    (defconst BOOT|FVT_WONDERCOACH_TREASURY:string      "WonderCoachTreasury")
    (defconst BOOT|FVT_STOICISM_VAULT:string            "StoicismVault")
    (defconst BOOT|POOL_STOICISM:string                 "StoicismPool")
    ;;CLASS CONSTANTS, named rather than written as digits at the call site. The two sovereign
    ;;admission rules disagree about SF/NF (see Step 8's @doc), so the one thing that must not be
    ;;a bare literal is the class.
    ;;  treasury(2) admits score-class 3/4  -- NosferatuDracula(4), WonderCoach(3)
    ;;  vault(1)    admits score-class 1/2  -- StoicPower(1)
    ;;TF-in/TF-out is the case BOTH rules describe identically, so the Stoicism vault does not
    ;;depend on how that dispute is settled; the two treasuries follow the same class the four
    ;;existing ones were issued at.
    (defconst BOOT|FVT_CLASS_VAULT:integer              1)
    (defconst BOOT|FVT_CLASS_TREASURY:integer           2)
    (defconst BOOT|POOL_CLASS_TF:integer                1)

    ;;<---------------------------------------------------------------------->
    ;; CUSTODIANS DELEGATED-STAKING VAULT (Steps 13-14). Added 2026-09-19.
    ;;
    ;; WHY THIS IS A CLASS-0 FVT AND NOT A TREASURY. It was specified as "a DSA Treasury",
    ;; and it behaves like one -- users stake an SFT collection, no LP is involved. But
    ;; 08_DSA.pact:292 refuses anything else outright:
    ;;     (enforce (= (RPS.UR_FVT|FvtClass fvt-id) 0) "DSA vault must be a class-0 FVT")
    ;; and AQP.repl <<AQP-G20b>> pins that refusal for a class-1 vault. The reason is in that
    ;; test's own note: capture arithmetic is denominated in an LP denominator, which classes
    ;; 1 and 2 do not have. Delegation members are then admitted through
    ;; RPS::XE_AdmitDelegationMember with swpair "|" and ghost-tvl 0.0, which SKIPS every LP
    ;; rule and the triplet-category<->fvt-class check. So class 0 is the container; the
    ;; behaviour is vault-like. Same shape as OuroLpFarm, which is the working precedent for
    ;; triplet + MULTIPLET_BASE + quality split.
    (defconst BOOT|FVT_CUSTODIANS_VAULT:string          "CustodiansVault")
    (defconst BOOT|POOL_CUSTODIANS:string               "CustodiansPool")
    (defconst BOOT|MODEL_CUSTODIANS_BRONZE:string       "CustodiansBronzeQuintessence")
    (defconst BOOT|MODEL_CUSTODIANS_SILVER:string       "CustodiansSilverQuintessence")
    (defconst BOOT|MODEL_CUSTODIANS_GOLDEN:string       "CustodiansGoldenQuintessence")
    (defconst BOOT|MODEL_CUSTODIANS_TRIPLET:string      "CustodiansQuintessenceTriplet")

    ;; ONE number sets both published thresholds. `unit-score` is quintessence per capture
    ;; unit -- "1 staking unit = 1 node" -- and UEV_OpenGate (08_DSA.pact:672) requires only
    ;; HALF of it to open an agency:
    ;;     (enforce (>= (URC_AgencyQuintessence score-entity-id) (/ (dec unit-score) 2.0)))
    ;; So 20000 => a node at 20000 and an agency at 10000. Do not add a second constant for
    ;; the agency gate; there is no second knob, and inventing one would let the two drift.
    (defconst BOOT|CUSTODIANS_UNIT_SCORE:integer        20000)

    ;; HETEROGENEOUS quality split, per-mille, each row summing to 1000. Rows are read as
    ;; [to-t0 to-t1 to-t2] against the MULTIPLET ladder, which for this vault is the
    ;; OURO|AURYN|ELITEAURYN family from Step 10 -- so t0=OURO, t1=Auryn, t2=Elite-Auryn.
    ;;   bronze  20% OURO / 40% Auryn / 40% Elite-Auryn
    ;;   silver  40% / 30% / 30%
    ;;   golden  60% / 20% / 20%
    (defconst BOOT|CUSTODIANS_SPLIT_BRONZE:[integer]    [200 400 400])
    (defconst BOOT|CUSTODIANS_SPLIT_SILVER:[integer]    [400 300 300])
    (defconst BOOT|CUSTODIANS_SPLIT_GOLDEN:[integer]    [600 200 200])

    ;; QUINTESSENCE PER CUSTODIANS UNIT — owner values, 2026-09-19.
    ;;     nonce 1 Bronze   1 000 whole   ·  1  per fragment
    ;;     nonce 2 Silver  10 000 whole   ·  10 per fragment
    ;;     nonce 3 Golden 100 000 whole   ·  100 per fragment
    ;;     nonce 4 OG      1 000, GOLDEN type, NOT fragmentable — plus a 5% anchor boost (below)
    ;;
    ;; WHY WHOLE AND FRAGMENT CARRY THE SAME NUMBER. URCx_SfStakeDefinitionWeightedRawWeight
    ;; scales a NEGATIVE (fragment) nonce by 0.001 and a whole by 1.0, and one whole splits into
    ;; exactly 1000 fragments. So a single value per tier expresses both:
    ;;     1 whole bronze      = 1000 x 1.000 x 1    = 1000
    ;;     1000 bronze frags   = 1000 x 0.001 x 1000 = 1000
    ;;     1 bronze fragment   = 1000 x 0.001 x 1    = 1
    ;; Listing only the negatives (as the Kursan DSA fixtures do) would make a WHOLE nonce score
    ;; ZERO. <<TX-BOOT-14>> stakes whole nonces precisely to keep that path honest.
    ;;
    ;; CORRECTED 2026-09-19: these were 1.0 / 10.0 / 100.0 — the right RATIO but 1000x too small,
    ;; taken from the collection's "a third of ownership over 10000/1000/100 units" description
    ;; rather than from the quintessence schedule. The ratio held, so every test still passed;
    ;; only the absolute scale was wrong, which is the kind of error a ratio-preserving fixture
    ;; cannot see. It matters: the whole collection is 30,000,000 quintessence, not 30,000, so at
    ;; unit-score 20000 it supports ~1500 capture units rather than one.
    (defconst BOOT|CUSTODIANS_NONCES_BRONZE:[integer]   [1 -1])
    (defconst BOOT|CUSTODIANS_NONCES_SILVER:[integer]   [2 -2])
    (defconst BOOT|CUSTODIANS_NONCES_GOLDEN:[integer]   [3 -3 4])
    (defconst BOOT|CUSTODIANS_VALUE_BRONZE:[decimal]    [1000.0 1000.0])
    (defconst BOOT|CUSTODIANS_VALUE_SILVER:[decimal]    [10000.0 10000.0])
    ;; Golden carries nonce 4 as a THIRD entry: the OG Founder SFT scores 1000 of the golden
    ;; type. It has no fragment negative because nonce 4 is not fragmentable.
    (defconst BOOT|CUSTODIANS_VALUE_GOLDEN:[decimal]    [100000.0 100000.0 1000.0])

    ;; NONCE 4 IS ALSO AN ANCHOR — +5% on the staked quintessence, owner ruling 2026-09-19.
    ;; ank-promile is per-mille and the boost is ADDITIVE (02_SCORE.pact: boosted = base x
    ;; promile/1000, stored as the boost PART, not a replacement), so 5% is 50.0.
    ;; The anchor is issued ONCE with the vault (Step 13); each agency's three scores link to
    ;; the class in Step 14, which is why the boost lands on the user's WHOLE staked
    ;; quintessence and not just the golden lane.
    (defconst BOOT|CUSTODIANS_OG_ANCHOR:string          "CustodiansOgFounder")
    (defconst BOOT|CUSTODIANS_OG_BOOST_CLASS:string     "CustodiansOgBoost")
    (defconst BOOT|CUSTODIANS_OG_PROMILE:decimal        50.0)
    (defconst BOOT|CUSTODIANS_OG_NONCE:integer          4)
    (defconst BOOT|CUSTODIANS_ANK_PRECISION:integer     3)
    (defconst BOOT|CUSTODIANS_PRECISION:integer         24)
    ;;Mirrors AQP-FVT/RPS CT_REWARD_MODE_HETEROGENEOUS. Restated rather than referenced because a
    ;;defconst is not reachable through a module reference -- (ref-FVT::CT_...) is "Cannot apply
    ;;value to non-closure". Pinned against the real thing by <<TX-BOOT-13>>, which reads the mode
    ;;back out of RPS after Step 13 writes it, so a drift in either spelling fails the suite.
    (defconst BOOT|REWARD_MODE_HETEROGENEOUS:string     "HETEROGENEOUS")
    (defconst BOOT|TREASURY_COMMON:string               "|")
    (defconst BOOT|SCORE_ENTITY_SCORE:integer           1)
    (defconst BOOT|SCORE_ENTITY_TRIPLET:integer         3)
    ;;{3.2}  schemas
    ;;{3.3}  tables

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
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;Step 0 - Wire AQP sovereign IMC policies + AQP|SC_NAME vault governor (run once after module deploy)
    ;;Step 1 - Create the Bunny Set Definition
    ;;Step 2 - Create the BronzeSnakePower, SilverSnakePower and GoldenSnakePower Anchor-Class Definitions
    ;;Step 3 - Create the UnityBooster, StoaBooster and VestaBooster Anchor-Class Definitions
    ;;Step 4 - Create the TheCodingDivision, Bloodshed, DemiourgosShareholder and DemiourgosSnakes Score Definitions
    ;;Step 5 - Create the SubsidiaryCodingDivision, SubsidiaryWonderCoach, SubsidiaryBloodshed, SubsidiaryNosferatu and SubsidiaryBunnies Score Definitions
    ;;Step 6 - Create the Ouro LP Triplet Score Definition
    ;;Step 7 - Create six DH pools (class 3/4 by entity) + class-0 OURO LP pool; assign Step4/5/6 scores
    ;;Step 8 - Issue five FVT entities (farm + vault treasuries) — C_Issue only
    ;;Step 9 - C_AddScoreEntity (type 1) on vault/treasury FVT entities (not farm LP triplet)
    ;;Step 10 - C_IssueMultipletFamily (OURO / Auryn / Elite-Auryn ATS ladder)
    ;;Step 11 - C_IssueTriplet + C_AddScoreEntity (type 3) + C_AddRewardLink (OURO + multiplet-family) on OuroLpFarm
    ;;Step 12 - C_AddRewardLink on vault/treasury FVT entities (plain rewards)

    ;;<=========================================================================>
    ;;{5.4}  Validate [UEV]
    ;;
    (defun UEV_BootStepState (step-name:string what:string actual:integer expected:integer)
        @doc "Refuses a bootstrap step whose CHAIN STATE says it has already completed. \
            \ \
            \ WHY THIS EXISTS, 2026-10-02. These steps are one-shot populators and none of \
            \ them was re-run-safe. Every id they create comes from U|DALOS::UDC_Makeid, \
            \ which seeds on <prev-block-hash> -- block-level, not per-tx. A second run in \
            \ the SAME block collides on a raw insert and aborts, which looks like protection \
            \ and is not: a second run in a LATER block gets fresh ids, inserts cleanly, and \
            \ leaves a COMPLETE DUPLICATE set of entities with no error anywhere. \
            \ \
            \ Observed on mainnet. C_DefinePrimordialSet computes (set-class = used + 1) and \
            \ inserts at that fresh key, so re-running Step 1 does not fail -- it adds a \
            \ second <Bunny RGB Set> at class 2, identically named, with the same recipe, and \
            \ the same 120 nonces then compose into either. \
            \ \
            \ A CHAIN-STATE CHECK, NOT A STEP LEDGER, and the difference is the point. A \
            \ ledger records that this module ran something; the state records that the THING \
            \ EXISTS. Only the second is true retroactively -- it refuses Step 1 on a chain \
            \ where the set was created before this guard was written, which no ledger row \
            \ could do. It also cannot drift from reality, which a ledger can."
        (enforce (= actual expected)
            (format
                "AQP-BOOT {} refused: {} is {}, expected {}. Either this step already ran -- \
                \ it is NOT re-runnable, a second run creates DUPLICATE entities rather than \
                \ failing -- or its predecessor step has not."
                [step-name what actual expected]
            )
        )
    )

    (defun C_Step0_WireImcAndGovernor:string
        (patron:string)
        @doc "Step 0 — AQP-POOL TFT + DPOF IMC + AQP|SC_NAME governor rotate. \
            \ Run once after all four sovereign AQP modules are on chain (before stake/unstake or Step 1+). \
            \ Prerequisite: AQP|SC_NAME smart account deployed (DALOS|A_DeploySmartAccount). \
            \ Talos TS02-C3 P|A_Define (P|TALOS-SUMMONER) is separate — sovereign executor / [4.0]. \
            \ FVT + VCT P|A_Define register IMP; FVT|RemoteAqpGov + VCT|RemoteAqpGov on AQP-POOL for vault legs."
        ;; INPUT
        ;;   patron — gas payer konto (REPL: KST.ANHD)
        ;; REPL: (AQP-BOOT.C_Step0_WireImcAndGovernor KST.ANHD)
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-P|AQP:module{OuronetPolicyV2} AQP-POOL)
                    (ref-P|RPS:module{OuronetPolicyV2} RPS)
                    (ref-P|FVT:module{OuronetPolicyV2} AQP-FVT)
                    (ref-P|VCT:module{OuronetPolicyV2} AQP-VCT)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV3} TS01-C1)
                    (ref-ANK:module{AcquisitionAnchorsV3} AQP-ANK)
                    ;;
                    (aqp-sc:string (ref-ANK::GOV|AQP|SC_NAME))
                )
                (ref-P|AQP::P|A_Define)
                (ref-P|RPS::P|A_Define)   ;; #75 B': RPS reward engine registers its guards on deps (royalty disposal)
                (ref-P|FVT::P|A_Define)
                (ref-P|VCT::P|A_Define)
                ;; C_RotateGovernor — AQP|SC_NAME: AQP-POOL.AQP|GOV (stake) + FVT|RemoteAqpGov + VCT|RemoteAqpGov.
                (ref-TS01-C1::DALOS|C_RotateGovernor patron aqp-sc
                    (let
                        (
                            (ref-U|G:module{OuronetGuardsV2} U|G)
                        )
                        (ref-U|G::UEV_GuardOfAny
                            [
                                (create-capability-guard (AQP-POOL.AQP|GOV))
                                (ref-P|AQP::P|UR "FVT|RemoteAqpGov")
                                (ref-P|AQP::P|UR "VCT|RemoteAqpGov")
                            ]
                        )
                    )
                )
                (format "AQP-BOOT Step 0 done. aqp-sc={}. TFT+DPOF IMC + gov wired. NEXT=Step1 or client txs." [aqp-sc])
            )
        )
    )
    (defun C_Step1_CreateBunnySet:string
        (patron:string kbn-id:string)
        @doc "Step 1 — Create Bunny set definition on KBN. INPUT: kbn-id from chain deploy. \
            \ OUTPUT echo: kbn-id. NEXT: Steps 2 and 3 use the same kbn-id."
        ;; INPUT
        ;;   patron   — gas payer konto (REPL: KST.ANHD)
        ;;   kbn-id   — KBN collection id already on chain (REPL: "KBN-98c486052a51")
        ;; OUTPUT (return string)
        ;;   kbn-id echoed — pass unchanged to Steps 2 and 3
        ;; REPL: (AQP-BOOT.C_Step1_CreateBunnySet KST.ANHD "KBN-98c486052a51")
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;AUTHORISATION FIRST (2026-09-14 ruling): the admin gate is acquired by the
            ;;with-capability above, so a non-admin is refused before this business check is
            ;;reached and the check can never be what shadows the gate.
            (UEV_BootStepState "Step1" "set-classes-used on the collection"
                (DPDC.UR_SetClassesUsed kbn-id false) 0)
            ;;A DOT CALL, AND IT PINS KBN'S CODE INTO THIS MODULE at AQP-BOOT's deploy time.
            ;;KBN implements no interface, so there is nothing to modref -- which is why this is
            ;;the only non-modref call in the file. The consequence is not theoretical:
            ;;
            ;;  block 621,458  KBN upgraded to write the Arweave artwork
            ;;  block 621,472  THIS step ran and wrote the OLD placeholder strings
            ;;
            ;;because AQP-BOOT had not been redeployed and was still carrying the KBN it was
            ;;compiled against. The set had to be repaired by hand with C_UpdateSetNonceURI.
            ;;
            ;;SO: ANY KBN CHANGE REQUIRES REDEPLOYING AQP-BOOT. `_dotpin.py --upgrade KBN` says
            ;;so mechanically, and `--check` is gate-fatal on a new unregistered dot edge.
            (KBN.A_BunnyRGBSet patron kbn-id)
            (format "AQP-BOOT Step 1 done. kbn-id={}. NEXT=Step2,Step3:kbn-id={}." [kbn-id kbn-id])
        )
    )
    (defun C_Step2_CreateSnakePowerAnchorClasses:string
        (patron:string kbn-id:string)
        @doc "Step 2 — SnakePower anchor classes (Bronze/Silver/Golden). INPUT: kbn-id from Step 1. \
            \ OUTPUT: anchor-ids, boost-class-ids. NEXT: Step 6 boost-class-ids=[Silver Bronze Golden]."
        ;; INPUT
        ;;   kbn-id — from Step 1 output
        ;; OUTPUT (return string)
        ;;   anchor-ids[4]       — OuroborosRain, AurynRain, EliteAurynRain, LegendarySnakeTokenRain
        ;;   boost-class-ids[3]  — emitted ONCE, in Step 6 order: silver, bronze, golden
        ;; NEXT
        ;;   Step 6: paste the bracketed list at the end of the output string directly into the
        ;;           `boost-class-ids` argument. It is already in Step 6 order (silver, bronze,
        ;;           golden) and already quoted. No reordering, no re-quoting.
        ;; REPL: (AQP-BOOT.C_Step2_CreateSnakePowerAnchorClasses KST.ANHD "KBN-98c486052a51")
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;Step 2 issues the collection's FIRST four anchors, so the asset's bookkeeping row
            ;;must still be empty. UR_AA|AnchorsActive is a with-default-read, so a collection
            ;;that has never been anchored answers 0 rather than aborting on a missing row.
            (UEV_BootStepState "Step2" "anchors-active on the collection"
                (AQP-ANK.UR_AA|AnchorsActive kbn-id) 0)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                    ;;
                    (bronze-boost-class-id:string (ref-U|DALOS::UDC_Makeid "BronzeSnakePower"))
                    (silver-boost-class-id:string (ref-U|DALOS::UDC_Makeid "SilverSnakePower"))
                    (golden-boost-class-id:string (ref-U|DALOS::UDC_Makeid "GoldenSnakePower"))
                    ;;
                    (anchor-ouroboros-rain-id:string (ref-U|DALOS::UDC_Makeid "OuroborosRain"))
                    (anchor-auryn-rain-id:string (ref-U|DALOS::UDC_Makeid "AurynRain"))
                    (anchor-elite-auryn-rain-id:string (ref-U|DALOS::UDC_Makeid "EliteAurynRain"))
                    (anchor-legendary-snake-token-rain-id:string (ref-U|DALOS::UDC_Makeid "LegendarySnakeTokenRain"))
                    ;;The EXECUTOR of an anchor issuance is the ANCHORED ASSET's owner, which is not
                    ;;necessarily the patron paying for it -- sovereign assets are owned by SMART
                    ;;accounts whose key the admin merely holds. Read it, never assume it.
                    (kbn-owner:string (AQP-ANK.URC_AnchorableAssetOwner kbn-id [false false]))
                )
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "OuroborosRain" kbn-id true "BronzeSnakePower" 3 50.0 "Background" "Ouroboros Rain")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "AurynRain" kbn-id true "SilverSnakePower" 3 100.0 "Background" "Auryn Rain")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "EliteAurynRain" kbn-id true "GoldenSnakePower" 3 200.0 "Background" "Elite-Auryn Rain")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "LegendarySnakeTokenRain" kbn-id false golden-boost-class-id 3 400.0 "Rarity" "Legendary")
                ;;OUTPUT SHAPE CHANGED 2026-09-18, for deployment use.
                ;;
                ;;It used to print the three boost classes TWICE, in two different orders: first
                ;;`boost-class-ids=[bronze silver golden]` (creation order) and then
                ;;`NEXT=Step6:[silver bronze golden]` (consumption order). An operator copying the
                ;;first list into Step 6 would wire the 50.0-weight class where the 100.0 belongs,
                ;;and NOTHING WOULD ERROR -- the pools would simply pay the wrong boosts forever.
                ;;
                ;;Now it prints them ONCE, in Step 6's order, as a QUOTED PACT LIST that can be
                ;;pasted straight into the `boost-class-ids` argument with no reordering and no
                ;;re-quoting. A format an operator has to transform is a format that will
                ;;eventually be transformed wrongly.
                ;;
                ;;No test asserts on this string -- both call sites are `print` -- so the change
                ;;breaks nothing. Verified before editing.
                (format "AQP-BOOT Step 2 done. kbn-id={}. anchors issued=[{} {} {} {}]. \
                        \ PASTE INTO Step6 boost-class-ids (silver bronze golden, already ordered): \
                        \ [\"{}\" \"{}\" \"{}\"]"
                    [
                        kbn-id
                        anchor-ouroboros-rain-id anchor-auryn-rain-id
                        anchor-elite-auryn-rain-id anchor-legendary-snake-token-rain-id
                        silver-boost-class-id bronze-boost-class-id golden-boost-class-id
                    ]
                )
            )
        )
    )
    (defun C_Step3_CreateBoosterAnchorClasses:string
        (patron:string kbn-id:string)
        @doc "Step 3 — Unity/Stoa/Vesta booster anchor classes. INPUT: kbn-id from Step 1. \
            \ OUTPUT: anchor-ids, boost-class-ids. NEXT: none required for Steps 4–7 (user ANK boosting)."
        ;; INPUT
        ;;   kbn-id — from Step 1 output
        ;; OUTPUT (return string)
        ;;   anchor-ids[11], boost-class-ids[3] — UnityBooster, StoaBooster, VestaBooster
        ;; REPL: (AQP-BOOT.C_Step3_CreateBoosterAnchorClasses KST.ANHD "KBN-98c486052a51")
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;EXACTLY FOUR, not "at least four". Step 2 leaves 4 and Step 3 adds 11, so 4 is the
            ;;only count that means "Step 2 done, Step 3 not" -- it pins the predecessor and the
            ;;re-run in one check. A >= would admit a second run of Step 3 at 15.
            (UEV_BootStepState "Step3" "anchors-active on the collection"
                (AQP-ANK.UR_AA|AnchorsActive kbn-id) 4)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                    ;;
                    (unity-boost-class-id:string (ref-U|DALOS::UDC_Makeid "UnityBooster"))
                    (stoa-boost-class-id:string (ref-U|DALOS::UDC_Makeid "StoaBooster"))
                    (vesta-boost-class-id:string (ref-U|DALOS::UDC_Makeid "VestaBooster"))
                    ;;
                    (anchor-elk0nite-id:string (ref-U|DALOS::UDC_Makeid "Elk0nite"))
                    (anchor-osmiridium-id:string (ref-U|DALOS::UDC_Makeid "Osmiridium"))
                    (anchor-titanium-id:string (ref-U|DALOS::UDC_Makeid "Titanium"))
                    (anchor-legendary-unity-booster-id:string (ref-U|DALOS::UDC_Makeid "LegendaryUnityBooster"))
                    (anchor-vegold-eyes-id:string (ref-U|DALOS::UDC_Makeid "VegoldEyes"))
                    (anchor-legendary-stoa-booster-id:string (ref-U|DALOS::UDC_Makeid "LegendaryStoaBooster"))
                    (anchor-red-eyes-id:string (ref-U|DALOS::UDC_Makeid "RedEyes"))
                    (anchor-green-eyes-id:string (ref-U|DALOS::UDC_Makeid "GreenEyes"))
                    (anchor-blue-eyes-id:string (ref-U|DALOS::UDC_Makeid "BlueEyes"))
                    (anchor-legendary-vesta-booster-id:string (ref-U|DALOS::UDC_Makeid "LegendaryVestaBooster"))
                    (anchor-rgb-eyes-id:string (ref-U|DALOS::UDC_Makeid "RGBEyes"))
                    ;;Anchor executor = the anchored asset's owner, read not assumed.
                    (kbn-owner:string (AQP-ANK.URC_AnchorableAssetOwner kbn-id [false false]))
                )
                ;; Unity
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "Elk0nite" kbn-id true "UnityBooster" 3 100.0 "Eyes" "Elk0nite Unity Glasses")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "Osmiridium" kbn-id false unity-boost-class-id 3 300.0 "Eyes" "Osmiridium Unity Glasses")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "Titanium" kbn-id false unity-boost-class-id 3 900.0 "Eyes" "Titaniumgold Unity Glasses")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "LegendaryUnityBooster" kbn-id false unity-boost-class-id 3 1000.0 "Rarity" "Legendary")
                ;; Stoa
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "VegoldEyes" kbn-id true "StoaBooster" 3 1000.0 "Eyes" "vEGLD Focus")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "LegendaryStoaBooster" kbn-id false stoa-boost-class-id 3 3500.0 "Rarity" "Legendary")
                ;; Vesta
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "RedEyes" kbn-id true "VestaBooster" 3 250.0 "Eyes" "Red")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "GreenEyes" kbn-id false vesta-boost-class-id 3 250.0 "Eyes" "Green")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "BlueEyes" kbn-id false vesta-boost-class-id 3 250.0 "Eyes" "Blue")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron kbn-owner "LegendaryVestaBooster" kbn-id false vesta-boost-class-id 3 3500.0 "Rarity" "Legendary")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleSetAnchor patron kbn-owner "RGBEyes" kbn-id false vesta-boost-class-id 3 1000.0 1)
                (format "AQP-BOOT Step 3 done. kbn-id={}. anchor-ids=[{} {} {} {} {} {} {} {} {} {} {}]. boost-class-ids=[unity={} stoa={} vesta={}]. NEXT=none-for-Steps4-7."
                    [
                        kbn-id
                        anchor-elk0nite-id anchor-osmiridium-id anchor-titanium-id anchor-legendary-unity-booster-id
                        anchor-vegold-eyes-id anchor-legendary-stoa-booster-id
                        anchor-red-eyes-id anchor-green-eyes-id anchor-blue-eyes-id anchor-legendary-vesta-booster-id anchor-rgb-eyes-id
                        unity-boost-class-id stoa-boost-class-id vesta-boost-class-id
                    ]
                )
            )
        )
    )
    (defun C_Step4_CreateCoreScores:string
        (patron:string owner-konto:string)
        @doc "Step 4 — Core scores (SF/NF). OUTPUT: score-ids ×4. NEXT: Step7 dh-score-ids slots 0,2,4,5."
        ;; INPUT
        ;;   patron, owner-konto — score owner (REPL: KST.ANHD for both)
        ;; OUTPUT (return string) — score-ids (UDC_Makeid names):
        ;;   TheCodingDivision, Bloodshed, DemiourgosShareholder, DemiourgosSnakes
        ;; NEXT Step 7 dh-score-ids[0,2,4,5] = these four ids (see README_AQP_BOOT.md index map)
        ;; REPL: (AQP-BOOT.C_Step4_CreateCoreScores KST.ANHD KST.ANHD)
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                    (score-coding:string (ref-U|DALOS::UDC_Makeid "TheCodingDivision"))
                    (score-bloodshed:string (ref-U|DALOS::UDC_Makeid "Bloodshed"))
                    (score-company-share:string (ref-U|DALOS::UDC_Makeid "DemiourgosShareholder"))
                    (score-company-snakes:string (ref-U|DALOS::UDC_Makeid "DemiourgosSnakes"))
                )
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "TheCodingDivision" 3 false)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "Bloodshed" 6 0)
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "DemiourgosShareholder" 6 true)
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "DemiourgosSnakes" 6 false)
                (format "AQP-BOOT Step 4 done. score-ids=[coding={} bloodshed={} company-share={} company-snakes={}]. NEXT=Step7:dh-score-ids[0,2,4,5]=[{} {} {} {}]."
                    [
                        score-coding score-bloodshed score-company-share score-company-snakes
                        score-coding score-bloodshed score-company-share score-company-snakes
                    ]
                )
            )
        )
    )
    (defun C_Step5_CreateSubsidiaryScores:string
        (patron:string owner-konto:string)
        @doc "Step 5 — Subsidiary scores. OUTPUT: score-ids ×5. NEXT: Step7 dh-score-ids slots 1,3,6,7,8."
        ;; INPUT
        ;;   patron, owner-konto — score owner (REPL: KST.ANHD for both)
        ;; OUTPUT (return string) — score-ids:
        ;;   SubsidiaryCodingDivision, SubsidiaryWonderCoach, SubsidiaryBloodshed, SubsidiaryNosferatu, SubsidiaryBunnies
        ;; NEXT Step 7 dh-score-ids[1,3,6,7,8] = these five ids
        ;; REPL: (AQP-BOOT.C_Step5_CreateSubsidiaryScores KST.ANHD KST.ANHD)
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                    (score-sub-coding:string (ref-U|DALOS::UDC_Makeid "SubsidiaryCodingDivision"))
                    (score-sub-wondercoach:string (ref-U|DALOS::UDC_Makeid "SubsidiaryWonderCoach"))
                    (score-sub-bloodshed:string (ref-U|DALOS::UDC_Makeid "SubsidiaryBloodshed"))
                    (score-sub-nosferatu:string (ref-U|DALOS::UDC_Makeid "SubsidiaryNosferatu"))
                    (score-sub-bunnies:string (ref-U|DALOS::UDC_Makeid "SubsidiaryBunnies"))
                )
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "SubsidiaryCodingDivision" 6 true)
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "SubsidiaryWonderCoach" 6 false)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "SubsidiaryBloodshed" 6 -1)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "SubsidiaryNosferatu" 6 -1)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "SubsidiaryBunnies" 6 -1)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron owner-konto score-sub-coding)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron owner-konto score-sub-wondercoach)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron owner-konto score-sub-bloodshed)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron owner-konto score-sub-nosferatu)
                (ref-TS02-C3::AQP-SCR|C_EnableDebBoost patron owner-konto score-sub-bunnies)
                ;;ORDERING BUG FIXED 2026-09-18. The `NEXT=Step7:dh-score-ids[1,3,6,7,8]` list used
                ;;to be emitted in CREATION order -- coding, wondercoach, bloodshed, nosferatu,
                ;;bunnies -- while slots [1,3,6,7,8] are coding, BLOODSHED, WONDERCOACH, nosferatu,
                ;;bunnies. Positions 2 and 3 were transposed against the slots the same string
                ;;names. An operator pasting it into Step 7 would put SubsidiaryWonderCoach in slot
                ;;3 and SubsidiaryBloodshed in slot 6, so DHBloodshed would carry the WonderCoach
                ;;subsidiary score and DHWonderCoach the Bloodshed one -- PERMANENTLY, and WITHOUT
                ;;ERRORING, because both are valid score ids.
                ;;Now emitted in slot order, and as a quoted pasteable list. Same defect class as
                ;;Step 2's boost-class ordering, fixed the same day.
                (format "AQP-BOOT Step 5 done. score-ids=[sub-coding={} sub-wondercoach={} sub-bloodshed={} sub-nosferatu={} sub-bunnies={}] deb-boost=enabled×5. \
                        \ PASTE INTO Step7 dh-score-ids slots [1,3,6,7,8] IN THIS ORDER: \
                        \ [\"{}\" \"{}\" \"{}\" \"{}\" \"{}\"]"
                    [
                        score-sub-coding score-sub-wondercoach score-sub-bloodshed score-sub-nosferatu score-sub-bunnies
                        score-sub-coding score-sub-bloodshed score-sub-wondercoach score-sub-nosferatu score-sub-bunnies
                    ]
                )
            )
        )
    )
    (defun C_Step6_CreateOuroLpTriplet:string
        (patron:string owner-konto:string lp-denominator:string boost-class-ids:[string])
        @doc "Step 6 — Issue OURO LP triplet **scores only** (Silver/Bronze/Golden class-0). \
            \ Does not create a pool or farm links — wire those in Step 7 (first LP) or manually per new LP line."
        ;;
        ;; WHAT THIS STEP DOES (scores only — no pool, no FVT)
        ;; Creates three class-0 liquidity scores sharing one lp-denominator (full OURO DPTF id):
        ;;   SilverSnakePower  — primary; owns user base-score for the triplet boost chain
        ;;   BronzeSnakePower  — foreign boost-link → Silver
        ;;   GoldenSnakePower  — foreign boost-link → Silver
        ;; Each score also gets a boost-class-link from Step 2 anchor classes.
        ;;
        ;; lp-denominator — full native DPTF id of the OURO pool leg (NOT ticker "OURO"):
        ;;   REPL example: "OURO-98c486052a51"
        ;;   Must match the Farm FVT common-denominator when scores are later admitted to a farm.
        ;;
        ;; boost-class-ids[0..2] — from Step 2 (SnakePower anchor classes).
        ;;
        ;; !! MAINNET: PASTE THESE FROM STEP 2's OUTPUT. DO NOT RECOMPUTE THEM.
        ;; The `UDC_Makeid` forms shown below are the REPL shape, and they are correct ONLY when
        ;; Step 2 ran in the same block -- which is true in the REPL (one prev-block-hash for the
        ;; whole suite) and false on mainnet, where Step 2 is its own transaction. Recomputing here
        ;; yields three ids that do not exist, the triplet wires to nothing, and no test can catch
        ;; it. Step 2's output ends with a ready-to-paste `["silver" "bronze" "golden"]` list for
        ;; exactly this argument.
        ;;
        ;;   0 silver-boost-class-id  e.g. (U|DALOS.UDC_Makeid "SilverSnakePower")
        ;;   1 bronze-boost-class-id  e.g. (U|DALOS.UDC_Makeid "BronzeSnakePower")
        ;;   2 golden-boost-class-id  e.g. (U|DALOS.UDC_Makeid "GoldenSnakePower")
        ;;
        ;; Score ids created (fixed names — first OURO LP line only):
        ;;   (U|DALOS.UDC_Makeid "SilverSnakePower")
        ;;   (U|DALOS.UDC_Makeid "BronzeSnakePower")
        ;;   (U|DALOS.UDC_Makeid "GoldenSnakePower")
        ;;
        ;; AFTER Step 6 — per LP line (full flow: README.md § OURO LP onboarding flow):
        ;;   1. C_Issue class-0 pool (DHOuroLp) with native LP asset-id  ← Step 7
        ;;   2. C_AddScore × 3 — employ triplet on that pool              ← Step 7
        ;;   3. Users stake LP into pool → SCORE user rows update
        ;;   4. C_AddScoreEntity (type 3) on shared Farm FVT                     ← Step 11
        ;;   5. C_AddRewardLink (OURO, multiplet-family-id) on farm    ← Step 11
        ;;
        ;; SECOND OURO LP: repeat score issuance with **new score names** (cannot reuse ids),
        ;; then new pool + C_AddScore × 3 + C_IssueTriplet + C_AddScoreEntity (type 3) on the same farm.
        ;;
        ;; REPL call (after Steps 2–3 anchor classes exist):
        ;; (AQP-BOOT.C_Step6_CreateOuroLpTriplet
        ;;   KST.ANHD
        ;;   KST.ANHD
        ;;   "OURO-98c486052a51"
        ;;   [(U|DALOS.UDC_Makeid "SilverSnakePower") (U|DALOS.UDC_Makeid "BronzeSnakePower") (U|DALOS.UDC_Makeid "GoldenSnakePower")]
        ;; )
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;FIXED 2026-09-12: the LENGTH check is enforced HERE, above the binding group.
            ;;It used to sit BELOW a `let` that already did `(at 0 boost-class-ids)`, `(at 1 …)` and
            ;;`(at 2 …)`. A `let` is EAGER, so for a SHORT list those indexes ran first and the
            ;;operator got `Array index out of bounds` instead of the sentence naming the argument.
            ;;The message only ever arrived for a list that was too LONG -- the one case the `at`s
            ;;survive. C_Step9 in this same file is the correctly-ordered twin, so the fix was
            ;;demonstrated in place. A length test needs nothing but the parameter, so it can run
            ;;before anything is derived. Pinned by REPL/modules/DPDC.repl <<DPDC-G10>>.
            (enforce (= (length boost-class-ids) 3) "Step 6 expects boost-class-ids=[silver bronze golden].")
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                    ;;
                    (silver-id:string (ref-U|DALOS::UDC_Makeid BOOT|SCORE_SILVER))
                    (bronze-id:string (ref-U|DALOS::UDC_Makeid BOOT|SCORE_BRONZE))
                    (golden-id:string (ref-U|DALOS::UDC_Makeid BOOT|SCORE_GOLDEN))
                    ;;
                    (silver-boost-class-id:string (at 0 boost-class-ids))
                    (bronze-boost-class-id:string (at 1 boost-class-ids))
                    (golden-boost-class-id:string (at 2 boost-class-ids))
                )
                ;; [1..2] Silver
                (ref-TS02-C3::AQP-SCR|C_IssueLiquidityScore
                    patron owner-konto BOOT|SCORE_SILVER BOOT|PRECISION lp-denominator BOOT|MX_FROZEN BOOT|MX_SLEEPING
                )
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostClassLink patron owner-konto silver-id silver-boost-class-id)
                ;; [3..5] Bronze
                (ref-TS02-C3::AQP-SCR|C_IssueLiquidityScore
                    patron owner-konto BOOT|SCORE_BRONZE BOOT|PRECISION lp-denominator BOOT|MX_FROZEN BOOT|MX_SLEEPING
                )
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostClassLink patron owner-konto bronze-id bronze-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostLink patron owner-konto bronze-id silver-id)
                ;; [6..8] Golden
                (ref-TS02-C3::AQP-SCR|C_IssueLiquidityScore
                    patron owner-konto BOOT|SCORE_GOLDEN BOOT|PRECISION lp-denominator BOOT|MX_FROZEN BOOT|MX_SLEEPING
                )
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostClassLink patron owner-konto golden-id golden-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostLink patron owner-konto golden-id silver-id)
                ;;
                (format "AQP-BOOT Step 6 done. lp-denominator={}. score-ids=[silver={} bronze={} golden={}]. \
                        \ boost-class-ids-IN=[{} {} {}]. boost-links=[{}->{} {}->{}]. \
                        \ PASTE INTO Step7 ouro-triplet-score-ids (these are the SCORES made here, \
                        \ NOT the Step 2 boost classes of the same name): [\"{}\" \"{}\" \"{}\"]."
                    [
                        lp-denominator
                        silver-id bronze-id golden-id
                        silver-boost-class-id bronze-boost-class-id golden-boost-class-id
                        bronze-id silver-id golden-id silver-id
                        silver-id bronze-id golden-id
                    ]
                )
            )
        )
    )
    (defun C_Step7_CreatePoolsAndScores:string
        (patron:string dh-asset-ids:[string] ouro-lp-asset-id:string dh-score-ids:[string] ouro-triplet-score-ids:[string])
        @doc "Step 7 — Issue six DH pools (class 3 or 4 by entity) plus one class-0 OURO LP pool and assign existing scores. \
            \ All ids are caller-supplied so this step can run after Steps 4–6 in separate transactions. \
            \ Pool aqp-class is fixed per entity (see ;; block). This step does not create FVT links."
        ;;
        ;; POOL MAP (aqp-class is fixed in code — pass the matching native collection id in dh-asset-ids)
        ;; | Pool name         | aqp-class | pass in dh-asset-ids     | Scores attached                                         |
        ;; | DHCodingDivision  | 3 DPSF    | DHCD-… dpsf-id           | TheCodingDivision, SubsidiaryCodingDivision             |
        ;; | DHBloodshed       | 4 DPNF    | DHB-… dpnf-id            | Bloodshed, SubsidiaryBloodshed                          |
        ;; | DHCompany         | 3 DPSF    | E|DH-… dpsf-id           | DemiourgosShareholder, DemiourgosSnakes                 |
        ;; | DHWonderCoach     | 3 DPSF    | DHWC-… dpsf-id           | SubsidiaryWonderCoach + the UI-issued CORE WonderCoach  |
        ;; | DHNosferatu       | 4 DPNF    | DHN-… dpnf-id            | SubsidiaryNosferatu + the UI-issued CORE Nosferatu      |
        ;; | DHBunnies         | 4 DPNF    | KBN-… dpnf-id            | SubsidiaryBunnies                                       |
        ;; | DHOuroLp          | 0 LP      | native LP id             | SilverSnakePower, BronzeSnakePower, GoldenSnakePower    |
        ;;
        ;; dh-asset-ids[0..5] — REPL examples (replace suffix with mainnet hash):
        ;;   0 "DHCD-98c486052a51"
        ;;   1 "DHB-98c486052a51"
        ;;   2 "E|DH-98c486052a51"
        ;;   3 "DHWC-98c486052a51"
        ;;   4 "DHN-98c486052a51"
        ;;   5 "SBN-98c486052a51"   (the Bunnies collection is SBN-, not KBN-)
        ;; ouro-lp-asset-id — e.g. "W|SSTOA-OURO-WSTOA|LP-98c486052a51"
        ;;
        ;; dh-pool-ids[0..5]:
        ;;   [(U|DALOS.UDC_Makeid "DHCodingDivision") (U|DALOS.UDC_Makeid "DHBloodshed") (U|DALOS.UDC_Makeid "DHCompany")
        ;;    (U|DALOS.UDC_Makeid "DHWonderCoach") (U|DALOS.UDC_Makeid "DHNosferatu") (U|DALOS.UDC_Makeid "DHBunnies")]
        ;; ouro-lp-pool-id — (U|DALOS.UDC_Makeid "DHOuroLp")
        ;;
        ;; !! MAINNET, AND THE TWO HALVES OF THIS STEP BEHAVE DIFFERENTLY:
        ;;
        ;;   dh-pool-ids / ouro-lp-pool-id  -- SAFE to recompute with UDC_Makeid. This step CREATES
        ;;      those pools, in this transaction, so the id it derives is the id it makes. The
        ;;      `UDC_Makeid "DHCodingDivision"` forms above are correct on mainnet.
        ;;
        ;;   dh-score-ids / ouro-triplet-score-ids  -- MUST BE PASTED FROM EARLIER OUTPUTS. The
        ;;      nine scores are created in Steps 4 and 5, the three triplet scores in Step 2, all
        ;;      in their own transactions and therefore their own blocks. The `UDC_Makeid` forms
        ;;      below are the REPL shape and are WRONG on mainnet. They look right, they typecheck,
        ;;      and the suite passes -- because the REPL runs every step under one prev-block-hash.
        ;;      Take these ids from the return strings of Steps 2, 4 and 5.
        ;;
        ;; dh-score-ids[0..10] — 0-8 from Steps 4-5; 9-10 are the UI-issued CORE scores:
        ;;   [TheCodingDivision SubsidiaryCodingDivision Bloodshed SubsidiaryBloodshed
        ;;    DemiourgosShareholder DemiourgosSnakes SubsidiaryWonderCoach SubsidiaryNosferatu
        ;;    SubsidiaryBunnies  <core-wondercoach>  <core-nosferatu>]
        ;; ouro-triplet-score-ids[0..2] — from Step 6:
        ;;   [SilverSnakePower BronzeSnakePower GoldenSnakePower]
        ;;
        ;; !! THE CALL TAKES FIVE ARGUMENTS. This example used to show SEVEN -- it still passed
        ;; !! `dh-pool-ids` and `ouro-lp-pool-id`, which were removed when this step started MINTING
        ;; !! those pools and deriving their ids itself. Pasting the old shape gives an arity error,
        ;; !! and the example is the thing an operator actually copies. Corrected 2026-10-06.
        ;;
        ;; REPL call (copy/paste; swap ids for mainnet):
        ;; (AQP-BOOT.C_Step7_CreatePoolsAndScores
        ;;   KST.ANHD
        ;;   ["DHCD-98c486052a51" "DHB-98c486052a51" "E|DH-98c486052a51" "DHWC-98c486052a51" "DHN-98c486052a51" "SBN-98c486052a51"]
        ;;   "W|SSTOA-OURO-WSTOA|LP-98c486052a51"
        ;;   [(U|DALOS.UDC_Makeid "TheCodingDivision") (U|DALOS.UDC_Makeid "SubsidiaryCodingDivision")
        ;;    (U|DALOS.UDC_Makeid "Bloodshed") (U|DALOS.UDC_Makeid "SubsidiaryBloodshed")
        ;;    (U|DALOS.UDC_Makeid "DemiourgosShareholder") (U|DALOS.UDC_Makeid "DemiourgosSnakes")
        ;;    (U|DALOS.UDC_Makeid "SubsidiaryWonderCoach") (U|DALOS.UDC_Makeid "SubsidiaryNosferatu")
        ;;    (U|DALOS.UDC_Makeid "SubsidiaryBunnies")
        ;;    (U|DALOS.UDC_Makeid "WonderCoach") (U|DALOS.UDC_Makeid "Nosferatu")]
        ;;   [(U|DALOS.UDC_Makeid "SilverSnakePower") (U|DALOS.UDC_Makeid "BronzeSnakePower") (U|DALOS.UDC_Makeid "GoldenSnakePower")]
        ;; )
        (with-capability (GOV|AQP_BOOT_ADMIN)
            ;;FIXED 2026-09-12: all FOUR length checks are enforced HERE, above the binding group.
            ;;They used to sit BELOW a `let` that indexes every one of these lists -- (at 0 dh-score-ids)
            ;;through (at 8 dh-score-ids), and so on. A `let` is EAGER, so for any list that was too
            ;;SHORT the indexes ran first and the operator got `Array index out of bounds` instead of
            ;;the sentence naming which argument was wrong. Six operator-facing messages in this file
            ;;arrived only when a list was too LONG -- the one case the `at`s survive.
            ;;C_Step9 in this same file is the correctly-ordered twin. Length tests need nothing but
            ;;the parameters, so they run before anything is derived.
            ;;Pinned by REPL/modules/DPDC.repl <<DPDC-G10>>.
                (enforce (= (length dh-asset-ids) 6) "Step 7 expects dh-asset-ids=[coding bloodshed company wondercoach nosferatu bunnies].")
                (enforce (= (length dh-score-ids) 11) "Step 7 expects dh-score-ids=[coding sub-coding bloodshed sub-bloodshed company-share company-snakes sub-wondercoach sub-nosferatu sub-bunnies core-wondercoach core-nosferatu].")
                (enforce (= (length ouro-triplet-score-ids) 3) "Step 7 expects ouro-triplet-score-ids=[silver bronze golden].")
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    ;;
                    (asset-coding:string (at 0 dh-asset-ids))
                    (asset-coding-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 3 asset-coding))
                    (asset-bloodshed:string (at 1 dh-asset-ids))
                    (asset-bloodshed-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 4 asset-bloodshed))
                    (asset-company:string (at 2 dh-asset-ids))
                    (asset-company-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 3 asset-company))
                    (asset-wondercoach:string (at 3 dh-asset-ids))
                    (asset-wondercoach-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 3 asset-wondercoach))
                    (asset-nosferatu:string (at 4 dh-asset-ids))
                    (asset-nosferatu-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 4 asset-nosferatu))
                    (asset-bunnies:string (at 5 dh-asset-ids))
                    (asset-bunnies-owner:string (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 4 asset-bunnies))
                    ;;
                    ;;POOL IDS ARE DERIVED HERE, NOT PASSED IN. Changed 2026-09-18.
                    ;;They used to be two arguments -- `dh-pool-ids` (6) and `ouro-lp-pool-id` --
                    ;;which the caller had to supply. But this step MINTS these seven pools, from
                    ;;the very name literals used in the C_Issue calls below, in this transaction.
                    ;;`UDC_Makeid` on the same literal in the same transaction therefore returns
                    ;;exactly the id C_Issue is about to create. Passing them in could only ever
                    ;;match or be wrong; it could never be MORE right.
                    ;;
                    ;;Removing them takes seven values off the caller, removes one of the four
                    ;;length guards, and removes an entire class of operator error on mainnet.
                    ;;What remains as arguments is precisely what this step CANNOT know: the six
                    ;;live collection assets, and the twelve scores created in earlier blocks.
                    ;;THE POOL OWNERS ARE RESOLVED FROM THE ASSET, NOT READ FROM THE POOL ROW.
                    ;;
                    ;;FIXED 2026-10-06. These seven were `(AQP-POOL.URC_AqpOwnerKonto pool-X)` --
                    ;;a read of `AQP|T|Pool` for a pool THIS TRANSACTION HAS NOT CREATED YET. A
                    ;;Pact `let` is EAGER, so all seven ran before the `C_Issue` calls in the body
                    ;;below, and the step aborted on the first one:
                    ;;
                    ;;    No value found in table ouronet-ns.AQP-POOL_AQP|T|Pool for key: DHCodingDi...
                    ;;
                    ;;Step 7 could therefore never have succeeded, on any chain, since the day it
                    ;;was written.
                    ;;
                    ;;THE VALUE IS IDENTICAL, which is why this is a fix and not a workaround:
                    ;;`URC_AqpOwnerKonto` is DEFINED as
                    ;;`(URC_AqpOwnerKontoFromClassAndAsset (UR_AQP|PoolAqpClass p) (UR_AQP|PoolAssetId p))`
                    ;;-- it resolves the governor from the pool's class and asset, having first
                    ;;read those two fields off the row. We already hold both as literals here, so
                    ;;the row lookup is the only thing being removed. The sibling resolver is
                    ;;documented for exactly this case: "issue-time or PRE-POOL-ROW".
                    ;;
                    ;;These are now the same bindings the `C_Issue` executor uses one block below,
                    ;;which is also the honest statement of the fact: the pool's governor IS the
                    ;;asset's governor.
                    (pool-coding:string (ref-U|DALOS::UDC_Makeid "DHCodingDivision"))
                    (pool-coding-owner:string asset-coding-owner)
                    (pool-bloodshed:string (ref-U|DALOS::UDC_Makeid "DHBloodshed"))
                    (pool-bloodshed-owner:string asset-bloodshed-owner)
                    (pool-company:string (ref-U|DALOS::UDC_Makeid "DHCompany"))
                    (pool-company-owner:string asset-company-owner)
                    (pool-wondercoach:string (ref-U|DALOS::UDC_Makeid "DHWonderCoach"))
                    (pool-wondercoach-owner:string asset-wondercoach-owner)
                    (pool-nosferatu:string (ref-U|DALOS::UDC_Makeid "DHNosferatu"))
                    (pool-nosferatu-owner:string asset-nosferatu-owner)
                    (pool-bunnies:string (ref-U|DALOS::UDC_Makeid "DHBunnies"))
                    (pool-bunnies-owner:string asset-bunnies-owner)
                    (pool-ouro-lp:string (ref-U|DALOS::UDC_Makeid "DHOuroLp"))
                    ;;
                    (score-coding:string (at 0 dh-score-ids))
                    (score-sub-coding:string (at 1 dh-score-ids))
                    (score-bloodshed:string (at 2 dh-score-ids))
                    (score-sub-bloodshed:string (at 3 dh-score-ids))
                    (score-company-share:string (at 4 dh-score-ids))
                    (score-company-snakes:string (at 5 dh-score-ids))
                    (score-sub-wondercoach:string (at 6 dh-score-ids))
                    (score-sub-nosferatu:string (at 7 dh-score-ids))
                    ;;THE TWO CORE SCORES, added 2026-10-06. They are NOT created by any boot step --
                    ;;the owner issues them from the UI, because they are deliberately NOT DEB-enhanced
                    ;;and carry hand-built weight tables (WonderCoach: per-nonce, rarity x set
                    ;;completeness; Nosferatu: one rarity worth twice the last). Steps 4-5 make the nine
                    ;;Subsidiary/primary scores; these two ride in beside them so the pool that stakes
                    ;;their collection scores BOTH -- the subsidiary weighting and the core one.
                    ;;Passed in rather than derived: UDC_Makeid would be wrong, exactly as it is for the
                    ;;other nine, because they were issued in their own blocks.
                    (score-core-wondercoach:string (at 9 dh-score-ids))
                    (score-core-nosferatu:string (at 10 dh-score-ids))
                    (score-sub-bunnies:string (at 8 dh-score-ids))
                    (score-silver:string (at 0 ouro-triplet-score-ids))
                    (score-bronze:string (at 1 ouro-triplet-score-ids))
                    (score-golden:string (at 2 ouro-triplet-score-ids))
                    ;;The LP pool's executor is the LP token's owner konto -- read, not assumed.
                    (ouro-lp-asset-owner:string
                        (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset 0 ouro-lp-asset-id))
                )
                ;;
                ;; [1] DHCodingDivision — aqp-class 3 (DPSF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-coding-owner "DHCodingDivision" asset-coding 3)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-coding-owner pool-coding score-coding)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-coding-owner pool-coding score-sub-coding)
                ;; [2] DHBloodshed — aqp-class 4 (DPNF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-bloodshed-owner "DHBloodshed" asset-bloodshed 4)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bloodshed-owner pool-bloodshed score-bloodshed)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bloodshed-owner pool-bloodshed score-sub-bloodshed)
                ;; [3] DHCompany — aqp-class 3 (DPSF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-company-owner "DHCompany" asset-company 3)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-company-owner pool-company score-company-share)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-company-owner pool-company score-company-snakes)
                ;; [4] DHWonderCoach — aqp-class 3 (DPSF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-wondercoach-owner "DHWonderCoach" asset-wondercoach 3)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-wondercoach-owner pool-wondercoach score-sub-wondercoach)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-wondercoach-owner pool-wondercoach score-core-wondercoach)
                ;; [5] DHNosferatu — aqp-class 4 (DPNF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-nosferatu-owner "DHNosferatu" asset-nosferatu 4)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-nosferatu-owner pool-nosferatu score-sub-nosferatu)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-nosferatu-owner pool-nosferatu score-core-nosferatu)
                ;; [6] DHBunnies — aqp-class 4 (DPNF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-bunnies-owner "DHBunnies" asset-bunnies 4)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bunnies-owner pool-bunnies score-sub-bunnies)
                ;; [7] DHOuroLp — aqp-class 0 (LP); triplet from Step 6 — see Step 6 ;; for OURO LP flow
                (ref-TS02-C3::AQP-POOL|C_Issue patron ouro-lp-asset-owner "DHOuroLp" ouro-lp-asset-id 0)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron ouro-lp-asset-owner pool-ouro-lp score-silver)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron ouro-lp-asset-owner pool-ouro-lp score-bronze)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron ouro-lp-asset-owner pool-ouro-lp score-golden)
                ;;
                (format "AQP-BOOT Step 7 done. pool-ids=[coding={} bloodshed={} company={} wondercoach={} nosferatu={} bunnies={} ouro-lp={}]. ouro-lp-asset-id={}. score-slots-wired=14. NEXT=Step8:C_Step8_IssueFvtEntities."
                    [
                        pool-coding pool-bloodshed pool-company pool-wondercoach pool-nosferatu pool-bunnies pool-ouro-lp
                        ouro-lp-asset-id
                    ]
                )
            )
        )
    )
    (defun C_Step8_IssueFvtEntities:string
        (patron:string owner-konto:string lp-denominator:string)
        @doc "Step 8 — Issue five production FVT entities (C_Issue only). \
            \ OuroLpFarm class 0 when lp-denominator non-empty (same OURO DPTF id as Step 6). \
            \ Four class-1 vault treasuries with common-denominator '|'. \
            \ Product names say Treasury; they are issued at fvt-class 1. \
            \ !! 2026-09-19: TWO SOVEREIGN ADMISSION RULES DISAGREE ABOUT WHAT CLASS 1 MEANS. \
            \ URC_ScoreClassMatchesFvtClass (05_FVT.pact) says vault(1) admits score-class 1/3/4 \
            \ = TF/SF/NF and treasury(2) admits 2 = OF. URC_TripletCategoryMatchesFvtClass \
            \ (02_SCORE.pact) says VAULT_TF<->1 and TREASURY_SF_NF<->2, i.e. vault = TF only and \
            \ treasury = SF/NF. The schema comment at 05_FVT.pact:580 reads 0=Farm 1=Vault \
            \ 2=Treasury. Owner intent (2026-09-19): vaults take TF and OF, treasuries take SF \
            \ and NF -- which the TRIPLET rule matches and the SCORE rule does not. \
            \ This step issues four entities NAMED Treasury at class 1, and Step 9 links SF/NF \
            \ subsidiary scores to them; that passes only because the score rule permits 3/4 at \
            \ class 1. UNRESOLVED -- do not treat either rule as authoritative until ruled on. \
            \ NEXT=Step9 vault score links, Steps 10–11 farm triplet — pass fvt-ids from this output."
        ;;
        ;; INPUT
        ;;   patron, owner-konto — FVT owner (REPL: KST.ANHD)
        ;;   lp-denominator — full OURO DPTF id for OuroLpFarm; pass \"\" to skip farm (vault-only bootstrap)
        ;; OUTPUT — fvt-ids ×6 (farm skipped → echo farm=skipped)
        ;; REPL: see 2_CITIZEN/Stage_02/README_AQP_BOOT.md § Steps 8–12
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                    (farm-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_OURO_LP_FARM))
                    (sub-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_SUBSIDIARY_TREASURY))
                    (coding-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_CODING_TREASURY))
                    (snakes-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_SNAKES_TREASURY))
                    (shares-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_SHARES_TREASURY))
                    (bloodshed-treasury-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_BLOODSHED_TREASURY))
                )
                (if (!= lp-denominator "")
                    (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_OURO_LP_FARM 0 lp-denominator)
                    true
                )
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_SUBSIDIARY_TREASURY 2 BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_CODING_TREASURY 2 BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_SNAKES_TREASURY 2 BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_SHARES_TREASURY 2 BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_BLOODSHED_TREASURY 2 BOOT|TREASURY_COMMON)
                (format "AQP-BOOT Step 8 done. fvt-ids=[farm={} sub-treasury={} coding-treasury={} snakes-treasury={} shares-treasury={} bloodshed-treasury={}]. NEXT=Step9:C_AddScoreEntity."
                    [
                        (if (!= lp-denominator "") farm-id "skipped")
                        sub-treasury-id coding-treasury-id snakes-treasury-id shares-treasury-id
                        bloodshed-treasury-id
                    ]
                )
            )
        )
    )
    (defun C_Step9_AddFvtScoreEntities:string
        (patron:string sub-treasury-id:string coding-treasury-id:string snakes-treasury-id:string shares-treasury-id:string bloodshed-treasury-id:string subsidiary-score-ids:[string] coding-score-id:string snakes-score-id:string shares-score-id:string bloodshed-score-id:string)
        @doc "Step 9 — Admit score entities (type 1) on vault/treasury FVT entities only. \
            \ SubsidiaryTreasury: five subsidiary scores. \
            \ CodingDivisionTreasury: TheCodingDivision. SnakesTreasury: DemiourgosSnakes. \
            \ CompanySharesTreasury: DemiourgosShareholder. BloodshedTreasury: Bloodshed \
            \ (the PURE score from Step 4, not the subsidiary -- that one is in the five). \
            \ Farm OURO LP triplet is wired in Step 11."
        ;;
        ;; INPUT — fvt-ids from Step 8 output; score ids from Steps 4–5
        ;; REPL: see 2_CITIZEN/Stage_02/README_AQP_BOOT.md § Steps 8–12
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                )
                (enforce (= (length subsidiary-score-ids) 5) "Step 9 expects subsidiary-score-ids×5.")
                (map
                    (lambda (score-id:string)
                        (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto sub-treasury-id) sub-treasury-id BOOT|SCORE_ENTITY_SCORE score-id)
                    )
                    subsidiary-score-ids
                )
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto coding-treasury-id) coding-treasury-id BOOT|SCORE_ENTITY_SCORE coding-score-id)
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto snakes-treasury-id) snakes-treasury-id BOOT|SCORE_ENTITY_SCORE snakes-score-id)
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto shares-treasury-id) shares-treasury-id BOOT|SCORE_ENTITY_SCORE shares-score-id)
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto bloodshed-treasury-id) bloodshed-treasury-id BOOT|SCORE_ENTITY_SCORE bloodshed-score-id)
                (format "AQP-BOOT Step 9 done. score-entities=[sub=5 coding=1 snakes=1 shares=1]. fvt-ids=[sub-treasury={} coding-treasury={} snakes-treasury={} shares-treasury={}]. NEXT=Step10:C_IssueMultipletFamily."
                    [
                        sub-treasury-id coding-treasury-id snakes-treasury-id shares-treasury-id
                    ]
                )
            )
        )
    )
    (defun C_Step10_IssueMultipletFamily:string
        (patron:string ouro-id:string auryn-id:string elite-auryn-id:string ats-0-1-id:string ats-1-2-id:string)
        @doc "Step 10 — Issue chain-wide MultipletFamily (rank 3) for OURO→Auryn→Elite-Auryn Coil/Curl ladder. \
            \ INPUT: live DPTF ids + ATS pair ids (token-0 RT on ats-0-1; token-1 RBT/RT; token-2 RBT)."
        ;;
        ;; family-id = F|ouro-id|auryn-id|elite-auryn-id (deterministic — pass to Step 11)
        ;; REPL: ouro-id, auryn-id, elite-auryn-id from DALOS; ats ids from deployed ATS pairs
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                    (family-id:string (concat ["F" "|" ouro-id "|" auryn-id "|" elite-auryn-id]))
                )
                (ref-TS02-C3::AQP-FVT|C_IssueMultipletFamily
                    patron patron ouro-id auryn-id elite-auryn-id ats-0-1-id ats-1-2-id
                )
                (format "AQP-BOOT Step 10 done. multiplet-family-id={}. tokens=[ouro={} auryn={} elite={}] ats=[{} {}]. NEXT=Step11:C_IssueTriplet+AddScoreEntity."
                    [family-id ouro-id auryn-id elite-auryn-id ats-0-1-id ats-1-2-id]
                )
            )
        )
    )
    (defun C_Step11_WireFarmTriplet:string
        (patron:string farm-id:string bronze-score-id:string silver-score-id:string golden-score-id:string ouro-id:string multiplet-family-id:string)
        @doc "Step 11 — Issue triplet bundle, admit to OuroLpFarm (type 3), register OURO MULTIPLET_BASE reward. \
            \ Skip when farm-id empty or 'skipped'. INPUT: score ids from Step 6; family id from Step 10 echo."
        ;;
        ;; triplet-id = T|bronze|silver|golden (deterministic from score ids)
        ;; REPL: farm-id from Step 8; ouro-id = lp-denominator; multiplet-family-id from Step 10
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                    (wire-farm:bool
                        (and
                            (!= farm-id "")
                            (!= farm-id "skipped")
                        )
                    )
                    (triplet-id:string (concat ["T" "|" bronze-score-id "|" silver-score-id "|" golden-score-id]))
                )
                (if wire-farm
                    (do
                        (ref-TS02-C3::AQP-SCR|C_IssueTriplet patron patron bronze-score-id silver-score-id golden-score-id)
                        (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron (AQP-FVT.UR_FVT|OwnerKonto farm-id) farm-id BOOT|SCORE_ENTITY_TRIPLET triplet-id)
                        (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto farm-id) farm-id ouro-id false multiplet-family-id)
                    )
                    true
                )
                (format "AQP-BOOT Step 11 done. farm={} triplet-id={} multiplet-family-id={} ouro-reward={}. NEXT=Step12:C_AddRewardLink."
                    [
                        (if wire-farm farm-id "skipped")
                        (if wire-farm triplet-id "skipped")
                        (if wire-farm multiplet-family-id "skipped")
                        (if wire-farm ouro-id "skipped")
                    ]
                )
            )
        )
    )
    (defun C_Step12_AddFvtRewardLinks:string
        (patron:string sub-treasury-id:string coding-treasury-id:string snakes-treasury-id:string shares-treasury-id:string bloodshed-treasury-id:string reward-auryn-id:string reward-ouroboros-id:string reward-wstoa-id:string)
        @doc "Step 12 — Register reward tokens on treasury FVT entities via C_AddRewardLink (multiplet-family-id BAR). \
            \ SubsidiaryTreasury, SnakesTreasury → Auryn. CodingDivisionTreasury → Wstoa. \
            \ CompanySharesTreasury → Ouroboros. BloodshedTreasury → Auryn AND Wstoa (the only \
            \ multi-reward FVT here). Farm OURO + family is Step 11."
        ;;
        ;; INPUT — fvt-ids from Step 8; reward DPTF ids from live chain
        ;; REPL: AURYN-98c486052a51, DALOS::UR_OuroborosID, DALOS::UR_WrappedStoaID
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                    (ref-U|CT:module{OuronetConstantsV2} U|CT)
                    (bar:string (ref-U|CT::CT_BAR))
                )
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto sub-treasury-id) sub-treasury-id reward-auryn-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto coding-treasury-id) coding-treasury-id reward-wstoa-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto snakes-treasury-id) snakes-treasury-id reward-auryn-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto shares-treasury-id) shares-treasury-id reward-ouroboros-id false bar)
                ;;BloodshedTreasury earns TWO tokens -- owner ruling 2026-09-19: "add wstoa and
                ;;auryn for now on the pure bloodshed score vault". It is the only FVT here with
                ;;more than one reward; the other four take a single token each.
                ;;
                ;;This is supported by construction, not a workaround: FVT|T|RPS|Global is keyed
                ;;`fvt-id | dptf-id` (RPS::UCk_RpsGlobal), so reward state is per (FVT, token) and
                ;;UR_FVT|EnabledRewardCount exists to count them. Two links are two rows.
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto bloodshed-treasury-id) bloodshed-treasury-id reward-auryn-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto bloodshed-treasury-id) bloodshed-treasury-id reward-wstoa-id false bar)
                ;;LABELLING FIXED 2026-09-18. This read
                ;;  reward-links=[sub={} coding={} snakes={} shares={}]
                ;;fed with the REWARD TOKEN ids, so `sub=<auryn-id>` looked like it was naming the
                ;;sub-treasury when it was naming what the sub-treasury was linked TO -- and the
                ;;same three reward ids were then printed again under `rewards=`. Arity was always
                ;;correct; the labels were not, and the treasury ids the links actually attach to
                ;;did not appear at all. Now each link is printed as the PAIR it is.
                (format "AQP-BOOT Step 12 done. reward-links=[{}<-auryn {}<-wstoa {}<-auryn {}<-ouroboros {}<-auryn+wstoa]. rewards=[auryn={} wstoa={} ouroboros={}]. Bootstrap complete — ready for inject/stake/collect."
                    [
                        sub-treasury-id coding-treasury-id snakes-treasury-id shares-treasury-id
                        bloodshed-treasury-id
                        reward-auryn-id reward-wstoa-id reward-ouroboros-id
                    ]
                )
            )
        )
    )

    (defun C_Step13_CreateCustodiansVault:string
        (patron:string owner-konto:string custodians-dpsf-id:string ouro-id:string multiplet-family-id:string)
        @doc "Step 13 — stand up the Custodians DELEGATED-STAKING vault: three quintessence score \
            \ MODELS (bronze/silver/golden) + the triplet model every agency instantiates, a class-0 \
            \ FVT, a MULTIPLET_BASE OURO reward on the Step-10 ladder, the HETEROGENEOUS quality \
            \ split, the DSA template, and the pool the Custodians SFT stakes into. \
            \ Issues NO agency — that is Step 14, once per operator."
        ;;
        ;; INPUT
        ;;   custodians-dpsf-id  — the live Custodians DPSF collection id (REPL: DHOC-98c486052a51)
        ;;   ouro-id             — OURO DPTF id; BOTH the FVT common-denominator and the reward token
        ;;   multiplet-family-id — from Step 10. MUST be the OURO|AURYN|ELITEAURYN family: the
        ;;                         quality split routes per-mille across t0/t1/t2 OF THIS LADDER, so
        ;;                         a different family silently redirects every payout.
        ;; OUTPUT — fvt-id, pool-id, the four model ids. Step 14 needs the triplet model id.
        ;;
        ;; ORDER IS FORCED, not stylistic:
        ;;   * C_SetQualitySplit's own guard (04_RPS.pact UEV_QualitySplitContext) demands the reward
        ;;     link already exist, BE MULTIPLET_BASE, and carry an ACTIVE family. A reward link is
        ;;     MULTIPLET_BASE precisely when C_AddRewardLink is passed a family id instead of BAR.
        ;;     So: family (Step 10) -> reward link -> split. It cannot be reordered.
        ;;   * C_DefineDelegationVault requires the FVT to exist and be class 0, owned by patron.
        ;;   * The pool is issued here but its scores are added in Step 14 — they do not exist until
        ;;     an agency instantiates the model.
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                    (fvt-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_CUSTODIANS_VAULT))
                    (pool-id:string (ref-U|DALOS::UDC_Makeid BOOT|POOL_CUSTODIANS))
                    (bronze-model-id:string (ref-U|DALOS::UDC_Makeid BOOT|MODEL_CUSTODIANS_BRONZE))
                    (silver-model-id:string (ref-U|DALOS::UDC_Makeid BOOT|MODEL_CUSTODIANS_SILVER))
                    (golden-model-id:string (ref-U|DALOS::UDC_Makeid BOOT|MODEL_CUSTODIANS_GOLDEN))
                    (triplet-model-id:string (ref-U|DALOS::UDC_Makeid BOOT|MODEL_CUSTODIANS_TRIPLET))
                    (og-boost-class-id:string (ref-U|DALOS::UDC_Makeid BOOT|CUSTODIANS_OG_BOOST_CLASS))
                    ;;Anchor executor = the anchored SFT collection's owner, read not assumed.
                    (custodians-dpsf-owner:string
                        (AQP-ANK.URC_AnchorableAssetOwner custodians-dpsf-id [false true]))
                )
                ;; 1. the OG-Founder ANCHOR (+5%) and the boost class it creates. `acnoi` true means
                ;;    the next argument is a NAME to create rather than an existing class id.
                ;;    Issued once, here: the class is shared by every agency's scores (Step 14
                ;;    links them), which is what makes the 5% apply to a user's WHOLE staked
                ;;    quintessence rather than only the golden lane.
                (ref-TS02-C3::AQP-ANK|C_IssueSemiFungibleAnchor patron custodians-dpsf-owner BOOT|CUSTODIANS_OG_ANCHOR
                    custodians-dpsf-id true BOOT|CUSTODIANS_OG_BOOST_CLASS
                    BOOT|CUSTODIANS_ANK_PRECISION BOOT|CUSTODIANS_OG_PROMILE BOOT|CUSTODIANS_OG_NONCE)
                ;; 2. the three single models — score-class 3 (SemiFungible); v1 models are SF-only.
                ;;    Each carries og-boost-class-id, so every score minted from them is boost-linked
                ;;    AT ISSUE by the vault's rule. The agency never chooses.
                (ref-TS02-C3::AQP-SCR|C_IssueSingleScoreModel patron patron BOOT|MODEL_CUSTODIANS_BRONZE
                    3 custodians-dpsf-id BOOT|CUSTODIANS_PRECISION
                    BOOT|CUSTODIANS_NONCES_BRONZE BOOT|CUSTODIANS_VALUE_BRONZE og-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_IssueSingleScoreModel patron patron BOOT|MODEL_CUSTODIANS_SILVER
                    3 custodians-dpsf-id BOOT|CUSTODIANS_PRECISION
                    BOOT|CUSTODIANS_NONCES_SILVER BOOT|CUSTODIANS_VALUE_SILVER og-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_IssueSingleScoreModel patron patron BOOT|MODEL_CUSTODIANS_GOLDEN
                    3 custodians-dpsf-id BOOT|CUSTODIANS_PRECISION
                    BOOT|CUSTODIANS_NONCES_GOLDEN BOOT|CUSTODIANS_VALUE_GOLDEN og-boost-class-id)
                ;; 3. the triplet model — what every agency instantiates, so all agencies score alike
                (ref-TS02-C3::AQP-SCR|C_CombineTripletScoreModel patron patron BOOT|MODEL_CUSTODIANS_TRIPLET
                    bronze-model-id silver-model-id golden-model-id)
                ;; 4. the class-0 FVT. common-denominator is a REAL DPTF here, not BAR: DSA capture
                ;;    arithmetic is denominated in it, which is the whole reason class 1/2 is refused.
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto BOOT|FVT_CUSTODIANS_VAULT 0 ouro-id)
                ;; 5. MULTIPLET_BASE reward — the family id is what makes it so
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron (AQP-FVT.UR_FVT|OwnerKonto fvt-id) fvt-id ouro-id false multiplet-family-id)
                ;; 6. the heterogeneous split across the OURO|AURYN|ELITEAURYN ladder
                (ref-TS02-C3::AQP-FVT|C_SetQualitySplit patron (AQP-FVT.UR_FVT|OwnerKonto fvt-id) fvt-id ouro-id
                    BOOT|REWARD_MODE_HETEROGENEOUS
                    BOOT|CUSTODIANS_SPLIT_BRONZE BOOT|CUSTODIANS_SPLIT_SILVER BOOT|CUSTODIANS_SPLIT_GOLDEN)
                ;; 7. the DSA template — unit-score sets the node bar AND, at half, the agency bar
                (ref-TS02-C3::AQP-DSA|C_DefineDelegationVault patron patron fvt-id triplet-model-id
                    BOOT|CUSTODIANS_UNIT_SCORE)
                ;; 8. the pool the Custodians SFT stakes into — aqp-class 3 (DPSF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron custodians-dpsf-owner BOOT|POOL_CUSTODIANS custodians-dpsf-id 3)
                (format "AQP-BOOT Step 13 done. fvt={} pool={} triplet-model={} models=[bronze={} silver={} golden={}] og-boost-class={} (+5%% on nonce 4) unit-score={} (agency gate {}). NEXT=Step14:CC_Step14_OpenCustodiansAgency."
                    [
                        fvt-id pool-id triplet-model-id
                        bronze-model-id silver-model-id golden-model-id
                        (ref-U|DALOS::UDC_Makeid BOOT|CUSTODIANS_OG_BOOST_CLASS)
                        BOOT|CUSTODIANS_UNIT_SCORE (/ (dec BOOT|CUSTODIANS_UNIT_SCORE) 2.0)
                    ]
                )
            )
        )
    )
    (defun CC_Step14_OpenCustodiansAgency:string
        (patron:string agency-name:string custodians-dpsf-id:string stake-nonces:[integer] fee-per-mille:integer)
        @doc "Step 14 — open ONE Custodians agency: instantiate the triplet model for this operator, \
            \ HEAVY (CC_): reaches RPS::URH_FvtEnabledScoreEntityIdsForFvt through CC_OpenAgency's \
            \ stake leg, so its cost scales with the vault's score-entity count, not with a constant. \
            \ employ its three scores in the Custodians pool, then open the agency and stake in one \
            \ atomic Talos call. Run once per operator; the first run is the vault's first agency."
        ;;
        ;; INPUT
        ;;   patron         — THE OPERATOR. There is deliberately no separate operator parameter:
        ;;                    the operator is whoever calls. C_AdmitAgency admits with
        ;;                    `XE_AdmitDelegationMember fvt-id score-entity-id PATRON`, and
        ;;                    FVT|XE>ADMIT-DELEGATION then enforces `silver-owner == operator` plus
        ;;                    that operator's account ownership -- while CC_OpenAgency stakes from
        ;;                    patron too. An earlier draft took an `operator-konto` alongside
        ;;                    `patron`; it could only ever be the same value, and passing anything
        ;;                    else failed inside RPS with a message naming neither parameter. The
        ;;                    test passed because both were KST.ANHD, which is exactly how a
        ;;                    parameter that cannot vary looks like one that can.
        ;;                    The operator need NOT be the vault owner -- only the caller.
        ;;   agency-name    — names the three scores <agency-name>Bronze/Silver/Golden, so it must be
        ;;                    unique per agency or the second one collides on the branding table.
        ;;   stake-nonces   — the operator's OWN opening stake, e.g. [-1 -2 -3] for fragments of all
        ;;                    three tiers. This is not optional: UEV_OpenGate is TERMINAL inside
        ;;                    CC_OpenAgency, so a stake too small to reach unit-score/2 reverts the
        ;;                    whole open rather than leaving a half-built agency.
        ;;   fee-per-mille  — 10..500 (1%..50%), skimmed from DELEGATORS only, never the operator.
        ;;
        ;; WHY THE POOL LINKS HAPPEN HERE AND NOT IN STEP 13: the scores do not exist until this
        ;; call mints them, and RPS's FVT|XE>ADMIT-DELEGATION requires the SILVER score to carry a
        ;; pool link before it will admit the triplet. Employ-then-open, per agency.
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                    (ref-SCR:module{AcquisitionScoresV5} AQP-SCORE)
                    (fvt-id:string (ref-U|DALOS::UDC_Makeid BOOT|FVT_CUSTODIANS_VAULT))
                    (pool-id:string (ref-U|DALOS::UDC_Makeid BOOT|POOL_CUSTODIANS))
                    (pool-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-id))
                    (triplet-model-id:string (ref-U|DALOS::UDC_Makeid BOOT|MODEL_CUSTODIANS_TRIPLET))
                    (og-boost-class-id:string (ref-U|DALOS::UDC_Makeid BOOT|CUSTODIANS_OG_BOOST_CLASS))
                )
                ;; 1. the factory: 3 scores + their SF definitions + the triplet, in one call
                (ref-TS02-C3::AQP-SCR|C_IssueScoreFromModel patron patron triplet-model-id agency-name)
                (let
                    (
                        (bronze-id:string (ref-U|DALOS::UDC_Makeid (concat [agency-name "Bronze"])))
                        (silver-id:string (ref-U|DALOS::UDC_Makeid (concat [agency-name "Silver"])))
                        (golden-id:string (ref-U|DALOS::UDC_Makeid (concat [agency-name "Golden"])))
                    )
                    ;; 2. employ all three in the Custodians pool (silver's link is the one admission reads).
                    ;;    NOTE what is NOT here: boost-class links. Those used to be three explicit
                    ;;    C_CreateScoreBoostClassLink calls at this point, which was the defect --
                    ;;    they were made by the AGENCY, so an agency could decline the vault's anchor
                    ;;    or point at another class. The class now rides on the MODEL and is applied
                    ;;    by XI_IssueOneFromModel at issue, so step 1 above already linked all three.
                    ;;    The vault admin defines how a score behaves; the agency just opens.
                    (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-owner pool-id bronze-id)
                    (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-owner pool-id silver-id)
                    (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-owner pool-id golden-id)
                    ;; 3. admit + stake + gate, atomically
                    (ref-TS02-C3::AQP-DSA|CC_OpenAgency patron patron fvt-id pool-id
                        (ref-SCR::UC_ComputeTripletId bronze-id silver-id golden-id)
                        fee-per-mille custodians-dpsf-id stake-nonces)
                    (format "AQP-BOOT Step 14 done. agency={} triplet={} operator={} fee={}/1000 scores=[bronze={} silver={} golden={}]. NEXT: C_SetOracleAuth then C_OracleWrite — capture stays 0 until an oracle reports nodes."
                        [
                            agency-name
                            (ref-SCR::UC_ComputeTripletId bronze-id silver-id golden-id)
                            patron fee-per-mille bronze-id silver-id golden-id
                        ]
                    )
                )
            )
        )
    )
    ;;<=========================================================================>
    ;;  THE LATE STEPS — 7b, 8b, 9b, 12b   (added 2026-10-08)
    ;;
    ;;  WHY SEPARATE STEPS AND NOT EDITS TO 7/8/9/12.
    ;;    Steps 7 and 8 HAVE ALREADY RUN ON MAINNET. Step 8 minted six FVT entities, and
    ;;    `C_Issue` aborts on a duplicate name, so adding three entities to Step 8 would make
    ;;    that step permanently unrunnable rather than usefully extended. Step 7 likewise
    ;;    already created its seven pools. An additive step can run NOW, against the chain as
    ;;    it actually is; an edited one could only run on a chain that no longer exists.
    ;;
    ;;    Steps 9 and 12 have NOT run, so they COULD have been widened -- but Step 9 already
    ;;    takes 11 arguments and Step 12 nine, and both are hand-fed on mainnet from earlier
    ;;    transactions' output strings. Widening them to 17 and 15 would put the new work and
    ;;    the old work in one irreversible paste. These stay small and are run beside them.
    ;;
    ;;  ORDER: 7b and 8b are independent of each other and of everything else. 9b needs 8b
    ;;  (and, for StoicPower, 7b). 12b needs 8b. Nothing here needs 9 or 12 to have run.
    ;;<=========================================================================>
    (defun C_Step7b_CreateStoicismPool:string
        (patron:string stoicism-dptf-id:string stoic-power-score-id:string)
        @doc "Step 7b — The one pool Step 7 never made. Issues <StoicismPool> at aqp-class 1 \
            \ (non-LP true fungible) over the STOICISM DPTF and employs the existing StoicPower \
            \ score in it. Step 7 builds pools for the six DH collections and the OURO LP; \
            \ StoicPower is a true-fungible score over a plain token and belongs to neither \
            \ group, so it was left with no pool at all -- the only score on chain in that state. \
            \ NEXT=Step8b (the vault), then Step9b (admit), then Step12b (reward link)."
        ;;
        ;; INPUT
        ;;   stoicism-dptf-id    — the STOICISM DPTF id (the token users stake)
        ;;   stoic-power-score-id — the EXISTING StoicPower score, carried from its issue tx
        ;;
        ;; WHY NOT `C_IssueGenericEarningVault`, WHICH DOES ALL OF THIS IN ONE CALL:
        ;;   because it MINTS ITS OWN SCORE (`<name>Score`). StoicPower already exists, with its
        ;;   own weighting, and the request is to build a pool FOR IT. Calling the generic vault
        ;;   would stand up a second, empty `StoicismScore` beside it and leave StoicPower exactly
        ;;   as orphaned as it is now. The generic function remains the right tool for a vault
        ;;   that has no score yet; this is the variant for one that does.
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                    (pool-id:string (ref-U|DALOS::UDC_Makeid BOOT|POOL_STOICISM))
                    ;;THE STAKED ASSET'S OWNER, DERIVED -- not read from the pool row, which this
                    ;;transaction has not created yet. Step 7 aborted for exactly that reason on
                    ;;every chain until 2026-10-06: a Pact `let` is EAGER, so a read of
                    ;;`AQP|T|Pool` for a pool created later in the same body runs first and fails.
                    ;;`URC_AqpOwnerKontoFromClassAndAsset` is documented for the pre-pool-row case
                    ;;and resolves the same value the row would have held.
                    (stake-asset-owner:string
                        (AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset
                            BOOT|POOL_CLASS_TF stoicism-dptf-id))
                )
                (ref-TS02-C3::AQP-POOL|C_Issue
                    patron stake-asset-owner BOOT|POOL_STOICISM stoicism-dptf-id BOOT|POOL_CLASS_TF)
                ;;The executor on C_AddScore is the ASSET's owner, matching the issue above and
                ;;`AQP-FVT|C_IssueGenericEarningVault`'s own sequence -- a vault operator may
                ;;stake a token somebody else issued, so this is not necessarily `patron`.
                (ref-TS02-C3::AQP-POOL|C_AddScore
                    patron stake-asset-owner pool-id stoic-power-score-id)
                (format "AQP-BOOT Step 7b done. pool={} asset={} score={}. NEXT=Step8b:C_IssueLateFvtEntities."
                    [pool-id stoicism-dptf-id stoic-power-score-id]
                )
            )
        )
    )
    (defun C_Step8b_IssueLateFvtEntities:string
        (patron:string owner-konto:string)
        @doc "Step 8b — The three FVT entities Step 8 never issued. NosferatuTreasury and \
            \ WonderCoachTreasury at fvt-class 2 (treasury), matching the four Step 8 issued for \
            \ the other collection cores; StoicismVault at fvt-class 1 (vault), because \
            \ StoicPower is a true fungible and treasury admits only SF/NF. All three take the \
            \ BAR common denominator -- only a farm carries a real one. \
            \ SAFE TO RUN AFTER STEP 8: these are three NEW names, so nothing collides. \
            \ NEXT=Step9b with the three ids below."
        ;;
        ;; INPUT — patron, owner-konto (the FVT owner; the same account Step 8 used)
        ;; OUTPUT — three fvt-ids, to be pasted into Step 9b AND Step 12b
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                    (nosferatu-treasury-id:string
                        (ref-U|DALOS::UDC_Makeid BOOT|FVT_NOSFERATU_TREASURY))
                    (wondercoach-treasury-id:string
                        (ref-U|DALOS::UDC_Makeid BOOT|FVT_WONDERCOACH_TREASURY))
                    (stoicism-vault-id:string
                        (ref-U|DALOS::UDC_Makeid BOOT|FVT_STOICISM_VAULT))
                )
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto
                    BOOT|FVT_NOSFERATU_TREASURY BOOT|FVT_CLASS_TREASURY BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto
                    BOOT|FVT_WONDERCOACH_TREASURY BOOT|FVT_CLASS_TREASURY BOOT|TREASURY_COMMON)
                (ref-TS02-C3::AQP-FVT|C_Issue patron owner-konto
                    BOOT|FVT_STOICISM_VAULT BOOT|FVT_CLASS_VAULT BOOT|TREASURY_COMMON)
                (format "AQP-BOOT Step 8b done. fvt-ids=[nosferatu-treasury={} wondercoach-treasury={} stoicism-vault={}]. NEXT=Step9b:C_AddLateFvtScoreEntities."
                    [nosferatu-treasury-id wondercoach-treasury-id stoicism-vault-id]
                )
            )
        )
    )
    (defun C_Step9b_AddLateFvtScoreEntities:string
        (patron:string nosferatu-treasury-id:string wondercoach-treasury-id:string stoicism-vault-id:string core-nosferatu-score-id:string core-wondercoach-score-id:string stoic-power-score-id:string)
        @doc "Step 9b — Admit the three late scores (score-entity type 1) on the three Step 8b \
            \ entities: NosferatuDracula -> NosferatuTreasury, WonderCoach -> WonderCoachTreasury, \
            \ StoicPower -> StoicismVault. Independent of Step 9, which admits the nine scores \
            \ the boot ladder itself created. \
            \ A SCORE MAY BE ADMITTED ONCE: fvt-link is written once and never re-pointed, so \
            \ running this twice aborts rather than moving anything."
        ;;
        ;; INPUT — fvt-ids from Step 8b's output; the three score ids from their issue txs
        ;;
        ;; HARD PRECONDITION — EVERY SCORE HERE MUST ALREADY BE EMPLOYED IN A POOL.
        ;;   CORRECTED 2026-10-08. This note used to say Step 7b "must have run, or it has no
        ;;   pool and the aggregate still refuses its stakes" -- i.e. that admitting a pool-less
        ;;   score merely under-earns. It does not. It ABORTS:
        ;;
        ;;     No value found in table ouronet-ns.AQP-POOL_AQP|T|Pool for key: |
        ;;
        ;;   `URC_ResolveScoreEntitySwpair` (05_FVT.pact:1334) binds
        ;;   `(asset-id (UR_AQP|PoolAssetId pool-id))` in an EAGER `let`, so the pool row is read
        ;;   even at fvt-class 1/2 where the value is never used. A BAR pool-link is therefore
        ;;   fatal at admission, not at earning time.
        ;;
        ;;   On chain the two core scores are already pooled by Step 7; StoicPower is not, so
        ;;   STEP 7b MUST LAND BEFORE THIS STEP. Found by the REPL fixture, which minted the three
        ;;   scores and went straight here -- the error above is verbatim from that run.
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                )
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron
                    (AQP-FVT.UR_FVT|OwnerKonto nosferatu-treasury-id)
                    nosferatu-treasury-id BOOT|SCORE_ENTITY_SCORE core-nosferatu-score-id)
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron
                    (AQP-FVT.UR_FVT|OwnerKonto wondercoach-treasury-id)
                    wondercoach-treasury-id BOOT|SCORE_ENTITY_SCORE core-wondercoach-score-id)
                (ref-TS02-C3::AQP-FVT|C_AddScoreEntity patron
                    (AQP-FVT.UR_FVT|OwnerKonto stoicism-vault-id)
                    stoicism-vault-id BOOT|SCORE_ENTITY_SCORE stoic-power-score-id)
                (format "AQP-BOOT Step 9b done. admitted=[{}->{} {}->{} {}->{}]. NEXT=Step12b:C_AddLateFvtRewardLinks."
                    [
                        core-nosferatu-score-id nosferatu-treasury-id
                        core-wondercoach-score-id wondercoach-treasury-id
                        stoic-power-score-id stoicism-vault-id
                    ]
                )
            )
        )
    )
    (defun C_Step12b_AddLateFvtRewardLinks:string
        (patron:string nosferatu-treasury-id:string wondercoach-treasury-id:string stoicism-vault-id:string nosferatu-reward-id:string wondercoach-reward-id:string stoicism-reward-id:string)
        @doc "Step 12b — Register one reward token on each Step 8b entity. \
            \ NOT OPTIONAL: an employed score whose FVT has no enabled reward token makes every \
            \ stake abort in the FVT pipeline (05_FVT.pact:1210), so Steps 7b/8b/9b without this \
            \ one build three aggregators nobody can stake into. \
            \ THE REWARD TOKENS ARE PARAMETERS, NOT BAKED IN. Step 12 hardcodes its mapping \
            \ (sub/snakes->Auryn, coding->Wstoa, shares->Ouroboros, bloodshed->both) because \
            \ those were ruled on. Only the Stoicism one has been: owner, 2026-10-08 -- stake \
            \ Stoicism, earn WSTOA. What NosferatuTreasury and WonderCoachTreasury should pay \
            \ has not, so this step asks rather than guessing."
        ;;
        ;; INPUT — fvt-ids from Step 8b; three reward DPTF ids chosen by the operator
        ;;   stoicism-reward-id — WSTOA, per the owner ruling above
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV7} TS02-C3)
                    (ref-U|CT:module{OuronetConstantsV2} U|CT)
                    (bar:string (ref-U|CT::CT_BAR))
                )
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron
                    (AQP-FVT.UR_FVT|OwnerKonto nosferatu-treasury-id)
                    nosferatu-treasury-id nosferatu-reward-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron
                    (AQP-FVT.UR_FVT|OwnerKonto wondercoach-treasury-id)
                    wondercoach-treasury-id wondercoach-reward-id false bar)
                (ref-TS02-C3::AQP-FVT|C_AddRewardLink patron
                    (AQP-FVT.UR_FVT|OwnerKonto stoicism-vault-id)
                    stoicism-vault-id stoicism-reward-id false bar)
                (format "AQP-BOOT Step 12b done. reward-links=[{}<-{} {}<-{} {}<-{}]. The three late entities are now stakeable."
                    [
                        nosferatu-treasury-id nosferatu-reward-id
                        wondercoach-treasury-id wondercoach-reward-id
                        stoicism-vault-id stoicism-reward-id
                    ]
                )
            )
        )
    )
    (defun C_IssueGenericEarningVault:string
        (patron:string owner-konto:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
        @doc "Thin delegate to TS02-C3.AQP-FVT|C_IssueGenericEarningVault. Kept so existing callers \
            \ keep working; the operation itself moved to Talos on 2026-09-19."
        ;;WHY THE BODY MOVED. This used to compose the six TS02-C3 wrappers directly, and each of
        ;;those collects IGNIS on its own -- six collections for one logical operation. The work now
        ;;lives in TS02-C3, composing the six CORE C_ functions and concatenating their cumulators
        ;;into ONE collection. Single-collection billing is a Talos concern, not a citizen one, and
        ;;putting it there also makes the operation a public client feature rather than something
        ;;only the AQP-BOOT admin can reach.
        (TS02-C3.AQP-FVT|C_IssueGenericEarningVault
            patron owner-konto vault-name stake-dptf-id reward-dptf-id)
    )

)

