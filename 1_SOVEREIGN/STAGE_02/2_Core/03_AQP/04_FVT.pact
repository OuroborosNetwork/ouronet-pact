(interface AcquisitionFarmsVaultsTreasuriesV1


    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;{G5}  functions
    (defun GOV|Demiurgoi ())

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
    ;; [UC]  compute
    ;;
    (defun UCk_ScoreEntityLink:string (fvt-id:string score-entity-id:string))
    (defun UCk_RpsGlobal:string (fvt-id:string dptf-id:string))
    (defun UCk_RpsMember:string (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UCk_RpsUser:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    (defun UCk_MultipletFamily:string (token-0-id:string token-1-id:string token-2-id:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [UR]  read
    ;;
    (defun UR_FVT|FvtClass:integer (fvt-id:string))
    (defun UR_FVT|OwnerKonto:string (fvt-id:string))
    (defun UR_FVT|CanUpgrade:bool (fvt-id:string))
    (defun UR_FVT|CanChangeOwner:bool (fvt-id:string))
    (defun UR_FVT|VacateFrozen:bool (fvt-id:string))
    (defun UR_FVT|CommonDenominator:string (fvt-id:string))
    (defun UR_FVT|TotalGhostTvlWeight:decimal (fvt-id:string))
    (defun UR_FVT|TotalBaseScore:decimal (fvt-id:string))
    (defun UR_FVT|TotalBoostedScore:decimal (fvt-id:string))
    (defun UR_FVT|TotalDebScore:decimal (fvt-id:string))
    (defun UR_FVT|TotalNzsCount:integer (fvt-id:string))
    (defun UR_FVT|EnabledRewardCount:integer (fvt-id:string))
    (defun UR_FVT|MemberLinkCount:integer (fvt-id:string))
    (defun UR_FVT|Mosaic:bool (fvt-id:string))
    (defun UR_FVT|MembershipMode:string (fvt-id:string))
    (defun UR_FVT|SplitMode:string (fvt-id:string))
    (defun UR_FVT|OracleOn:bool (fvt-id:string))
    (defun UR_FVT|FvtId:string (fvt-id:string))
    ;;
    (defun UR_FVT-SEL|Enabled:bool (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|ScoreEntityType:integer (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|Swpair:string (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|GhostTvlWeight:decimal (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|Delegation:bool (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|CaptureUnits:decimal (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|CaptureWeight:decimal (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|OracleTs:time (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|FvtId:string (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|ScoreEntityId:string (fvt-id:string score-entity-id:string))
    ;;
    (defun UR_FVT-RM|LastFarmRpsG:decimal (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RM|MemberDebRps:decimal (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RM|PendingMemberRewards:decimal (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RM|FvtId:string (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RM|ScoreEntityId:string (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RM|DptfId:string (fvt-id:string score-entity-id:string dptf-id:string))
    ;;
    (defun UR_FVT-RG|RewardEnabled:bool (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|CurrentRps:decimal (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|AvailableRewards:decimal (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|UnclaimedCount:integer (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|ZombieRewards:decimal (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|RoyaltyRewards:decimal (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|Segmentation:bool (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|FvtId:string (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|DptfId:string (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|RewardKind:string (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|MultipletFamilyId:string (fvt-id:string dptf-id:string))
    ;;
    (defun UR_FVT-MF|Token0Id:string (multiplet-family-id:string))
    (defun UR_FVT-MF|Token1Id:string (multiplet-family-id:string))
    (defun UR_FVT-MF|Token2Id:string (multiplet-family-id:string))
    (defun UR_FVT-MF|Ats01Id:string (multiplet-family-id:string))
    (defun UR_FVT-MF|Ats12Id:string (multiplet-family-id:string))
    (defun UR_FVT-MF|Rank:integer (multiplet-family-id:string))
    (defun UR_FVT-MF|Active:bool (multiplet-family-id:string))
    (defun UR_FVT-MF|MultipletFamilyId:string (multiplet-family-id:string))
    ;;
    (defun UR_FVT-RU|LastRps:decimal (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RU|PendingRewards:decimal (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RU|UserId:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RU|FvtId:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RU|ScoreEntityId:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RU|DptfId:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT|SweepActive:bool (anchor-id:string))
    (defun URC_FvtUserHasStaleMember:bool (fvt-id:string user-id:string))
    (defun URC_FvtUserStaleMemberCount:integer (fvt-id:string user-id:string))
    (defun UR_FVT-FFC|Count:integer (fvt-id:string dptf-id:string user-id:string))
    ;; [URH] heavy-read
    (defun URH_FvtStalePresentUsers:[string] (fvt-id:string))
    (defun URH_FvtPresentUsers:[string] (fvt-id:string))
    (defun URHC_BuildStakeSettleBundle:object
        (pool-id:string beneficiary-id:string)
    )
    (defun UR_ExternalOracle:bool ())
    (defun UR_OracleValidity:integer ())
    (defun URCi_WithdrawRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string destination:string))
    (defun URCi_BurnRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string))
    (defun URCi_FuelRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string swpair:string))
    ;;
    ;; [URCi]   cost readers — single source for exec billing + INFO preview
    (defun URCi_Issue:object{IgnisCollectorV1.OutputCumulator} (owner-konto:string output:[string]))
    (defun URCi_IssueStoa:decimal ())
    (defun URCi_RotateOwnership:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string))
    (defun URCi_Control:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string))
    (defun URCi_SetCommonDenominator:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_SetMosaic:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_SetSplitMode:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_AddScoreEntity:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_ToggleScoreEntityLink:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_IssueMultipletFamily:object{IgnisCollectorV1.OutputCumulator} (patron:string output:[string]))
    (defun URCi_AddRewardLink:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_ToggleRewardLink:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_SetQualitySplit:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_Inject:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_UnstaleMyScores:object{IgnisCollectorV1.OutputCumulator} (patron:string output:[string]))
    (defun URCi_Collect:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string]))
    (defun URCi_CollectFull:decimal
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string))
    (defun URCi_TrueFungibleStakeFlow:decimal
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool))
    (defun URCi_OrtoFungibleStakeFlow:decimal
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] direction:bool))
    (defun URCi_CollectableStakeFlow:decimal
        (pool-id:string owner-id:string beneficiary-id:string collectable-id:string son:bool nonces:[integer] nonce-amounts:[integer] direction:bool))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;; [XE]
    (defun XE_FvtFixUserChunk:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string reward-dptf-id:string users:[string])
    )
    (defun XE_SweepSyncTripletLaneWeights:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string fvt-id:string score-entity-id:string)
    )
    (defun XE_FvtSweepRecomputeChunk:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string score-entity-id:string swept-boost-class-id:string users:[string])
    )
    (defun XE_SweepBegin:string (anchor-id:string))
    (defun XE_SweepEnd:string (anchor-id:string))
    (defun XE_SetFvtVacateFrozen:string (fvt-id:string frozen:bool))
    (defun XE_SetFvtOracleOn:string (fvt-id:string oracle-on:bool))
    (defun XE_SetExternalOracle:string (on:bool))
    (defun XE_SetOracleValidity:string (seconds:integer))
    (defun XE_SetAgencyFee:string (fvt-id:string score-entity-id:string operator-konto:string fee-per-mille:integer))
    (defun XE_SetMemberDelegation:string (fvt-id:string score-entity-id:string delegation:bool))
    (defun XE_SetMemberCapture:string (fvt-id:string score-entity-id:string capture-units:decimal capture-weight:decimal oracle-ts:time))
    (defun XE_AdmitDelegationMember:string (fvt-id:string triplet-id:string operator:string))
    (defun XE_WithdrawRoyalty:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string reward-dptf-id:string destination:string))
    (defun XE_BurnRoyalty:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string reward-dptf-id:string))
    (defun XE_FuelRoyalty:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string reward-dptf-id:string swpair:string))
    (defun XE_BankScorePendingRewards:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string plan:object)
    )
    (defun XE_RefreshTrueFungibleStakeAnchors:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
    )
    (defun XE_RefreshCollectableStakeAnchors:object{IgnisCollectorV1.OutputCumulator}
        (
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
    )
    (defun XE_BookStakeUnclaimedCounts:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object)
    )
    (defun XE_CheckpointStakeRps:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object)
    )
    ;; [XB]
    (defun XB_FvtInject:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    ;;{5.7}  User [A/C]
    (defun C_SetQualitySplit:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
    )
    ;; [C]   client
    ;;
    (defun CC_TrueFungibleStakeFlow:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    )
    (defun CC_OrtoFungibleStakeFlow:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
    )
    (defun CC_CollectableStakeFlow:object{IgnisCollectorV1.OutputCumulator}
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
    ;;
    (defun C_Issue:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
    )
    (defun C_RotateOwnership:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string new-owner-konto:string)
    )
    (defun C_Control:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
    )
    (defun C_SetCommonDenominator:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string common-denominator:string)
    )
    (defun C_SetMosaic:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string mosaic:bool)
    )
    (defun C_SetSplitMode:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string split-mode:string)
    )
    (defun C_AddScoreEntity:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string)
    )
    (defun C_ToggleScoreEntityLink:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
    )
    (defun C_IssueMultipletFamily:object{IgnisCollectorV1.OutputCumulator}
        (
            patron:string
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
        )
    )
    (defun C_AddRewardLink:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
    )
    (defun C_ToggleRewardLink:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string enabled:bool)
    )
    (defun CC_InjectStream:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
    )
    (defun CC_Inject:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun CCp_InjectFixChunk:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
    )
    (defun CC_InjectFinalize:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun CCp_UnstaleAll:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
    )
    (defun CC_SweepRevokeAnchor:string (patron:string anchor-id:string))
    (defun CC_SweepBegin:string (patron:string anchor-id:string))
    (defun CCp_SweepRecomputeChunk:string (patron:string anchor-id:string chunk:integer))
    (defun CC_UnstaleMyScores:object{IgnisCollectorV1.OutputCumulator} (patron:string fvt-ids:[string]))
    (defun CC_Collect:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
    )

)
(module AQP-FVT GOV




    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV1)
    (implements AcquisitionFarmsVaultsTreasuriesV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;(implements DemiourgosPactDigitalCollectibles-UtilityPrototype)
    ;;
    (defconst GOV|MD_FVT                    (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                          (compose-capability (GOV|FVT_ADMIN)))
    (defcap GOV|FVT_ADMIN ()                (enforce-guard GOV|MD_FVT))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))

    ;;<=========================================================================>
    ;;{2}  POLICY
    ;;{P1}  constants
    (defconst P|I                   (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV1.P|S})                      ;; Key = <policy-name>
    ;;  PURPOSE: Named keyset guards for this module (OuronetPolicyV1). Used by GOV|FVT_ADMIN and IMP registration.
    (deftable P|MT:{OuronetPolicyV1.P|MS})                     ;; Key = P|I (module-identity constant)
    ;;{P4}  capabilities
    ;;  PURPOSE: Multi-policy metadata — IMP guard list for cross-module capability checks.
    (defcap P|FVT|CALLER ()
        true
    )
    (defcap P|FVT|REMOTE-GOV ()
        @doc "Remote governor for AQP|SC_NAME vault TFT legs (inject/collect). Registered on AQP-POOL P|T as FVT|RemoteAqpGov."
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|FVT|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()                (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::P|Info)))
    (defun P|UR:guard (policy-name:string)
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        (at "m-policies" (read P|MT P|I ["m-policies"]))
    )
    (defun P|UEV_IMC ()
        (let
            (
                (ref-U|G:module{OuronetGuardsV1} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
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
        @doc "Post-deploy (AQP-BOOT Step 0): FVT SECURE on AQP-SCORE + AQP-POOL IMP; \
            \ P|FVT|CALLER on TFT/DPOF/DPDC-T; FVT|RemoteAqpGov on AQP-POOL for inject/collect vault legs. \
            \ Vacate recipes live in AQP-VCT."
        (let
            (
                (ref-P|SCR:module{OuronetPolicyV1} AQP-SCORE)
                (ref-P|AQP:module{OuronetPolicyV1} AQP-POOL)
                (ref-P|TFT:module{OuronetPolicyV1} TFT)
                (ref-P|DPOF:module{OuronetPolicyV1} DPOF)
                (ref-P|DPDC-T:module{OuronetPolicyV1} DPDC-T)
                (ref-P|DPTF:module{OuronetPolicyV1} DPTF)
                (ref-P|SWPLC:module{OuronetPolicyV1} SWPLC)
                (ref-P|ORBR:module{OuronetPolicyV1} OUROBOROS)
                (ref-P|ATSU:module{OuronetPolicyV1} ATSU)
                ;;
                (dg:guard (create-capability-guard (SECURE)))
                (mg:guard (create-capability-guard (P|FVT|CALLER)))
                (rg:guard (create-capability-guard (P|FVT|REMOTE-GOV)))
            )
            (ref-P|SCR::P|A_AddIMP dg)
            (ref-P|AQP::P|A_AddIMP dg)
            (ref-P|AQP::P|A_Add "FVT|RemoteAqpGov" rg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|DPDC-T::P|A_AddIMP mg)
            ;; DPTF: FVT burns the royalty pool in place from AQP|SC_NAME (DSA royalty burn disposal).
            (ref-P|DPTF::P|A_AddIMP mg)
            ;; SWPLC: FVT fuels a swpair with the royalty pool from AQP|SC_NAME (DSA royalty fuel disposal).
            (ref-P|SWPLC::P|A_AddIMP mg)
            ;; OUROBOROS: FVT normalizes an IGNIS royalty leg to OURO (XB_Compress) before disposal.
            (ref-P|ORBR::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst CT_FVT_RPS_PREC 48)
    (defconst FVT|DSA-ORACLE-KEY:string "GLOBAL")
    ;; --- Time-streamed inject (linear vesting release) — see Audit/STREAMED-INJECT-DESIGN.md ---
    (defconst STREAM_EPOCH:time (time "1970-01-01T00:00:00Z")
        "Default stream-last-release for a lane with no live stream (irrelevant while stream-count = 0).")
    (defconst STREAM_MIN_UPS 10000000
        "Anti-degeneracy floor: min smallest-token-units released per second for a streamed inject. \
       \ Precision-normalized — the effective min rate is STREAM_MIN_UPS * 10^(-reward-decimals), so it is \
       \ uniform across tokens (a 24-dp token clears it with a tiny amount; a 12-dp token needs ~0.864/24h).")
    (defconst STREAM_MAX_DURATION 31536000
        "Max stream duration in seconds (365 days).")
    (defconst STREAM_MIN_DURATION 3600
        "Min stream duration in seconds (1 hour). duration = 0 means an INSTANT inject (unchanged path).")
    (defconst STREAM_MAX_LANES 49
        "Hard ceiling on concurrent streams per lane (7x7 grid). The per-account cap (URC_MaxStreamLanes, by \
       \ Elite tier of the FVT owner konto) is always <= this.")
    ;; --- DSA (Delegated Staking Agencies) — see Audit/DSA-DELEGATED-STAKING-DESIGN.md ---
    (defconst DSA_ORACLE_TTL 90000
        "Oracle validity window in seconds (25h = a daily oracle write + 1h overlap, so there is never a gap \
       \ between last-write-expired and next-write). At inject, a delegation member whose last oracle write is \
       \ older than this (now − oracle-ts > DSA_ORACLE_TTL) captures NOTHING (effective weight 0 ⇒ its whole \
       \ share routes to the royalty pool). Only consulted when the FVT's oracle-on flag is set.")
    ;; --- Re-score sweep CC-batch gas backstop (loose ceiling + UI seed, mirrors the vacate cap philosophy) ---
    (defconst SWEEP-CHUNK-GAS-BUDGET 2000000
        "Nominal per-tx gas envelope the sweep CC-batch chunk cap is sized against (backstop, not the optimizer).")
    (defconst SWEEP-GAS-PER-HOLDER 2000
        "Per-holder backstop for the re-score recompute (settle across every reward stream + ANK aggregate \
       \ refold + deb refresh + mirror resync). MEASURED (REPL/Kursan/AQP-scale-sweep.repl, final hoisted \
       \ code): gas(n) = 81,040 + 1,684*n on a single-score/single-stream FVT → ~1,139 holders fit 2M. Set to \
       \ 2,000 (slope + ~19% margin) → SWEEP-CHUNK-MAX = 1,000 (1,000 holders = 1.77M, headroom). NOT the \
       \ optimizer: the UI sizes real chunks by simulating (/local) against the true model-dependent gas (richer \
       \ FVTs settle across more streams → higher per-holder → simulate lower), and the node gas meter is the \
       \ real enforcement (an oversized chunk aborts atomically — submitter's gas, offset unchanged, retry smaller).")
    (defconst SWEEP-CHUNK-MAX (/ SWEEP-CHUNK-GAS-BUDGET SWEEP-GAS-PER-HOLDER)
        "1,000 holders/chunk — the UI's optimistic seed + a coarse safety ceiling; refined by simulation.")
    ;; --- Enforced-fresh inject CC-batch fix backstop (loose ceiling + UI seed; same philosophy) ---
    (defconst INJECT-FIX-CHUNK-GAS-BUDGET 2000000
        "Nominal per-tx gas envelope the inject-fix chunk cap is sized against (backstop, not the optimizer).")
    (defconst INJECT-FIX-GAS-PER-USER 6500
        "Per-stale-user backstop for the enforced-fresh deb-fix (settle across every reward stream + deb refresh \
       \ + mirror resync). MEASURED (REPL/Kursan/AQP-scale-inject.repl, final hoisted code): gas(n) = 199,096 + \
       \ 5,189*n on a single-score/single-stream FVT → ~347 users fit 2M. Set to 6,500 (slope + ~25% margin) → \
       \ INJECT-FIX-CHUNK-MAX = 307 (307 users = 1.79M, headroom). NOT the optimizer — the UI sizes real chunks \
       \ by simulating (/local) and the node gas meter is the real ceiling; an oversized chunk aborts atomically \
       \ (retry smaller). Richer FVTs → higher fixed + per-user → simulate lower.")
    (defconst INJECT-FIX-CHUNK-MAX (/ INJECT-FIX-CHUNK-GAS-BUDGET INJECT-FIX-GAS-PER-USER)
        "307 stale users/chunk — the UI's optimistic seed + a coarse safety ceiling; refined by simulation.")
    ;; M3 #12 2e — IGNIS charged per inject-forced deb-fix, at the user's next collect (non-discountable). Governance
    ;; param (placeholder); set ≥ the IGNIS cost of self-fixing one score so self-fixing is always cheaper. ~10 IGNIS.
    (defconst CT_FORCED_FIX_RATE:decimal 10.0)
    (defconst BAR                                               (CT_Bar))
    (defconst AQP|SC_NAME                                       (CT_AqpScName))
    (defconst GAS|ISSUE-FVT                                     1000.0)
    (defconst GAS|ADD-SCORE-ENTITY                              500.0)
    (defconst GAS|ISSUE-MULTIPLET-FAMILY                        500.0)
    (defconst GAS|TOGGLE-SCORE-ENTITY-LINK                      500.0)
    (defconst GAS|SET-MOSAIC                                    500.0)
    (defconst GAS|ADD-REWARD-LINK                               500.0)
    (defconst GAS|TOGGLE-REWARD-LINK                            500.0)
    (defconst GAS|SET-QUALITY-SPLIT                             500.0)
    (defconst GAS|SET-COMMON-DENOMINATOR                        500.0)
    (defconst GAS|SET-SPLIT-MODE                                500.0)
    (defconst GAS|INJECT                                        500.0)
    (defconst GAS|COLLECT                                       500.0)
    (defconst GAS|UNSTALE                                       500.0)
    (defconst CT_REWARD_KIND_PLAIN                              "PLAIN")
    (defconst CT_REWARD_KIND_MULTIPLET_BASE                     "MULTIPLET_BASE")
    ;; Round B: a MULTIPLET_BASE triplet reward line can split each lane HOMOGENEOUSLY (each lane → one ladder
    ;; token: bronze→token-0, silver→token-1, gold→token-2) or HETEROGENEOUSLY (each lane → all 3 ladder tokens
    ;; per a stored per-mille matrix). Absent config ⇒ HOMOGENEOUS (unchanged behavior).
    (defconst CT_REWARD_MODE_HOMOGENEOUS                        "HOMOGENEOUS")
    (defconst CT_REWARD_MODE_HETEROGENEOUS                      "HETEROGENEOUS")
    (defconst CT_SCORE_ENTITY_SCORE                             1)
    (defconst CT_SCORE_ENTITY_TRIPLET                           3)
    (defconst CT_MEMBERSHIP_MODE_BAR                            "BAR")
    (defconst CT_MEMBERSHIP_MODE_SCORE                          "SCORE")
    (defconst CT_MEMBERSHIP_MODE_TRUE_TRIPLET                   "TRUE-TRIPLET")
    (defconst CT_MEMBERSHIP_MODE_STANDARD_TRIPLET               "STANDARD-TRIPLET")
    ;; Farm reward-split modes (D1-G2). Level-2 W_i source at inject; per-farm, freely mutable.
    (defconst CT_SPLIT_MODE_STAKED                             "SPLIT|STAKED") ;; Variant 1 — participation (farm default): W_i = member STAKED value (URC_MemberStakedStoaValue)
    (defconst CT_SPLIT_MODE_TVL                                "SPLIT|TVL")    ;; Variant 2 — pool-size: W_i = whole swpair TVL (UR_StoaValue)
    (defconst CT_SPLIT_MODE_NA                                 "|")            ;; sentinel — split-mode is farm-only; vaults/treasuries store this and never consult it
    ;;{3.2}  schemas
    ;;
    (defschema FVT|Schema
        @doc "Key = <FVT-ID>. One farm, vault, or treasury (FVT) entity: class, owner, enabled-reward-count, SCORE aggregate mirrors. \
            \ Farm (fvt-class 0): common-denominator + total-ghost-tvl-weight S is inject denominator. \
            \ Vault/Treasury: total-deb-score mirror for inject; common-denominator sentinel \"|\"; total-ghost-tvl-weight 0.0. \
            \ UrStoa analogue: vault header (urstoa-supply on SCORE side; S or total-deb here is FVT-side denominator). \
            \ Field tags: [.] fixed at issue; [..] fixed once set; [M] mutable; [Mu] mutable only under owner + can-upgrade."
        fvt-class:integer                                       ;;[.]   0=Farm (LP scores) · 1=Vault (TF | OF scores) · 2=Treasury (SF | NF scores).
        ;;                                                              Fixed at issue; enforced 0..2 (UEV_New). Only members whose score-class
        ;;                                                              matches this class are admitted (URC_ScoreClassMatchesFvtClass).
        owner-konto:string
        can-upgrade:bool
        can-change-owner:bool
        common-denominator:string                               ;;[Mu]  unsafe to change after ScoreEntityLinks
        total-ghost-tvl-weight:decimal                          ;;[M]   Farm S = sum enabled ScoreEntityLink W_i
        total-base-score:decimal
        total-boosted-score:decimal
        total-deb-score:decimal
        total-nzs-count:integer
        enabled-reward-count:integer
        member-link-count:integer                               ;;[M]   ScoreEntityLink rows (gates C_SetMosaic; no keys in defcap)
        mosaic:bool                                             ;;[Mu]  mix score + triplet entities when true
        membership-mode:string                                  ;;[Mu]  BAR | SCORE | TRUE-TRIPLET | STANDARD-TRIPLET
        oracle-on:bool                                          ;;[M]   DSA: node/uptime oracle governs capture (off ⇒ capture = units, uptime ≡ 1000, no expiry). Default false.
        split-mode:string                                       ;;[M]   Farm reward-split (D1-G2): SPLIT|STAKED (participation, farm default) | SPLIT|TVL (pool-size). The
        ;;                                                              Level-2 W_i source at inject. Farm (class 0) only; vault/treasury store the "|" (CT_SPLIT_MODE_NA) sentinel, never consulted.
        ;;
        ;;Select Keys
        fvt-id:string
    )
    (defschema FVT|ScoreEntityLink
        @doc "Key = <FVT-ID> | <Score-Entity-ID>. Unified membership — score (type 1) or triplet (type 3)."
        score-entity-type:integer                               ;;[.]   CT_SCORE_ENTITY_SCORE=1, CT_SCORE_ENTITY_TRIPLET=3
        enabled:bool                                            ;;[M]
        swpair:string                                           ;;[..]
        ghost-tvl-weight:decimal                                ;;[M]   Level-2 W_i (SWP staked value)
        total-lane-weight:decimal                               ;;[M]   Farm-triplet Level-1 divisor Σ w-user;
        ;;                                                              snapshot-maintained at stake/unstake (phase 4.6),
        ;;                                                              point-read as the L_i divisor (no staker scan).
        ;; DSA (Delegated Staking Agencies) — set only for a delegation member (= an agency); default
        ;; false/0.0/0.0/EPOCH for every normal member. DSA maintains them (delegator stake/unstake + the daily
        ;; oracle) via an XE_; FVT only ever READS its own fields at inject (dependency DSA -> FVT). See
        ;; Audit/DSA-DELEGATED-STAKING-DESIGN.md §3.
        delegation:bool                                         ;;[M]   is this member a DSA agency?
        capture-units:decimal                                   ;;[M]   ideal capacity = min(floor(Q/unit-score), nodes) — the IDEAL denominator term
        capture-weight:decimal                                  ;;[M]   actual = capture-units × uptime/1000 — the inject NUMERATOR
        oracle-ts:time                                          ;;[M]   timestamp of the last oracle write (now − ts > 25h ⇒ effective capture 0)
        ;;
        ;;Select Keys
        fvt-id:string                                           ;;[.]
        score-entity-id:string                                  ;;[.]   score-id or triplet-id T|…
    )
    (defschema FVT|MultipletFamily
        @doc "Key = F|<token-0-id>|<token-1-id>|<token-2-id>. Reward ladder for MULTIPLET_BASE collect."
        token-0-id:string
        token-1-id:string
        token-2-id:string
        ats-0-1-id:string
        ats-1-2-id:string
        rank:integer                                            ;;[.]   Lane count at issue (v1 = 3)
        active:bool
        ;;
        ;;Select Keys
        multiplet-family-id:string
    )
    (defschema FVT|QualitySplit
        @doc "Key = <FVT-ID> | <DPTF-ID> (same as RPS|Global). Round B: the per-FVT reward MODE + heterogeneous \
            \ split MATRIX for a MULTIPLET_BASE triplet reward. HOMOGENEOUS ⇒ each lane routes to its one ladder \
            \ token (bronze→t0, silver→t1, gold→t2) — the default when this row is absent. HETEROGENEOUS ⇒ each \
            \ lane splits across ALL 3 ladder tokens per its row [to-t0 to-t1 to-t2] (per-mille, sums to 1000): \
            \ bronze-split for the bronze lane, silver-split for silver, gold-split for gold. Per-FVT-reward + \
            \ owner-tunable (unlike the chain-wide immutable FVT|MultipletFamily ladder)."
        mode:string                                             ;;[M]   HOMOGENEOUS | HETEROGENEOUS
        bronze-split:[integer]                                  ;;[M]   [to-t0 to-t1 to-t2] per-mille, sums 1000
        silver-split:[integer]                                  ;;[M]
        gold-split:[integer]                                    ;;[M]
        ;;Select Keys
        fvt-id:string
        dptf-id:string
    )
    (defschema FVT|RPS|Global
        @doc "Key = <FVT-ID> | <DPTF-ID>. One registered reward DPTF on this FVT."
        reward-enabled:bool
        current-rps:decimal
        available-rewards:decimal
        unclaimed-count:integer
        ;; Escrow-on-empty (zombie/limbo): reward tokens injected while the inject denominator is 0 (no stakers)
        ;; are held here — physically in AQP|SC_NAME custody, counted, but NOT yet routed into G / available-rewards.
        ;; The next inject at a NON-zero denominator adds this on top of its amount, distributes the sum to whoever
        ;; is staked at that instant (pro-rata via G / farm-split), and zeroes it. Kept OUT of available-rewards so
        ;; the M1 last-claimant dust sweep can never pay a prior cohort the pending escrow. No owner reclaim: it
        ;; stays until a normal non-zero inject flushes it.
        zombie-rewards:decimal
        segmentation:bool
        reward-kind:string                                      ;;[.]   PLAIN | MULTIPLET_BASE
        multiplet-family-id:string                              ;;[.]   BAR or F|t0|t1|t2
        ;; Time-streamed inject (linear vesting) — the lane's active-stream ledger cursor. stream-count = live
        ;; stream positions (0 = none; the drip fast-returns). stream-last-release = shared lane checkpoint (every
        ;; active stream's start <= this, since a new stream is only added AFTER a drip). stream-unreleased =
        ;; custodied-but-not-yet-dripped total (held in AQP|SC_NAME, kept OUT of available-rewards / the M1 sweep
        ;; until the drip releases it). See Audit/STREAMED-INJECT-DESIGN.md.
        stream-count:integer
        stream-last-release:time
        stream-unreleased:decimal
        ;; DSA royalty pool: the uptime-shortfall slice of a delegation inject that no agency captured
        ;; (Σ capture-units − Σ effective capture-weight, worth A×that/Σunits). Custodied in AQP|SC_NAME, kept
        ;; OUT of available-rewards / G / the M1 sweep until the owner disposes it (withdraw / burn / fuel).
        ;; Always 0.0 on a non-delegation lane (Σ capture-weight == Σ capture-units ⇒ no shortfall).
        royalty-rewards:decimal
        ;;
        ;;Select Keys
        fvt-id:string
        dptf-id:string
    )
    (defschema FVT|RPS|Member
        @doc "Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>. Member reward line per score-entity × reward DPTF."
        last-farm-rps-g:decimal
        member-deb-rps:decimal
        pending-member-rewards:decimal
        ;;
        ;;Select Keys
        fvt-id:string
        score-entity-id:string
        dptf-id:string
    )
    (defschema FVT|RPS|User
        @doc "Key = <User-ID> | <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>. Per-staker row."
        last-rps:decimal
        pending-rewards:decimal
        user-id:string
        fvt-id:string
        score-entity-id:string
        dptf-id:string
    )
    (defschema FVT|RPS|Stream
        @doc "Key = <FVT-ID> | <DPTF-ID> | <position 1..49>. One live linear-release stream on a reward lane. \
            \ Positions are kept COMPACT (occupied = 1..stream-count); a finished stream is pruned and later \
            \ positions shift down. UI renders position n as tier-style major.minor (major = ceil(n/7), \
            \ minor = ((n-1) mod 7) + 1). rate = amount/duration (token-per-second, high precision); finish = \
            \ block-time the stream stops; amount = original streamed amount; released = cumulative released so \
            \ far, so the finish drip flushes (amount - released) and per-stream conservation is exact."
        rate:decimal
        finish:time
        amount:decimal
        released:decimal
        ;;
        ;;Select Keys
        fvt-id:string
        dptf-id:string
        position:integer
    )
    (defschema FVT|MemberVault
        @doc "Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID> (base ATS token). The per-member mini-vault for the \
            \ Tier-1 dust sweep (M1 / #10): available-rewards = rewards routed to this member (farm split-at-inject \
            \ slice, or vault Tier-2 earned) minus what its users have been paid; unclaimed-count = users in this \
            \ member with a live claim. When unclaimed-count hits 1, the member's last user is paid available-rewards \
            \ (sweeping the member's floor dust). Mirrors FVT|RPS|Global's available-rewards/unclaimed-count one tier down."
        available-rewards:decimal
        unclaimed-count:integer
        ;;
        ;;Select Keys
        fvt-id:string
        score-entity-id:string
        dptf-id:string
    )
    (defschema FVT|MemberUserWeight
        @doc "Key = <User-ID> | <FVT-ID> | <Score-Entity-ID>. Farm-triplet per-user Level-1 weight snapshot — \
            \ w-user (Σ lanes) as of the user's last score stake/unstake. Summed into \
            \ ScoreEntityLink.total-lane-weight and used as the user's Tier-1 numerator, so numerator and \
            \ divisor share one snapshot basis (reward conservation), exactly like a singular score uses \
            \ stored deb-score + maintained total-deb-score."
        contrib-weight:decimal
        ;;
        ;;Select Keys
        user-id:string
        fvt-id:string
        score-entity-id:string
    )
    (defschema FVT|UserPresence
        @doc "Key = <FVT-ID> | <Ouronet-ID>. Membership marker (M3 #12 / shared with the H4 anchor sweep): \
            \ is-present = true while the user holds a live position (nonzero weight) in AT LEAST ONE of this \
            \ FVT's score-entities. Written true (add-only) on every stake; recomputed to false on the unstake \
            \ that drops the user's LAST position in the FVT. Maintained for ALL FVT classes. Lets a sweep \
            \ enumerate one FVT's users with a single `select` over a small purpose-built table (no giant \
            \ RPS|User scan). A stale `true` is harmless — the sweep no-ops on a zero-weight user."
        is-present:bool
        ;;
        ;;Select Keys
        fvt-id:string
        ouronet-id:string
    )
    (defschema FVT|ForcedFixCount
        @doc "Key = <FVT-ID> | <DPTF-ID> | <User-ID>. M3 #12 2e penalty: how many of this user's stale scores an \
            \ enforced inject (CC_Inject / MTX|n|C_Inject) FORCE-fixed on this reward lane since the user last \
            \ collected it. At collect the user pays `count × RATE` NON-discountable IGNIS (a gas reimbursement — \
            \ the inject did N fixes for him; reward paid is untouched) and the count is zeroed. Self-fixing at \
            \ collect (PHASE 6 backstop) does NOT bump this — only inject-forced fixes do, so self-fixing stays \
            \ the cheaper path."
        count:integer
        ;;
        ;;Select Keys
        fvt-id:string
        dptf-id:string
        user-id:string
    )
    (defschema FVT|SettleFvtRewards
        @doc "One distinct FVT row in URH_FVT|SettleFvtRewardBundle."
        fvt-id:string
        reward-dptf-ids:[string]
    )
    (defschema FVT|SettleScorePlan
        @doc "One score-entity row in URC_SettleScorePlanRows — entity + fvt + reward list."
        score-entity-type:integer
        score-entity-id:string
        fvt-id:string
        reward-dptf-ids:[string]
    )
    (defschema FVT|ScorePreNzFlag
        @doc "Pre-SCORE snapshot for one employed score."
        score-id:string
        was-nz:bool
    )
    (defschema FVT|MemberPreDeb
        @doc "Pre-SCORE live deb-weight snapshot for one settled member (M2/#11 incremental total-deb mirror). \
            \ Self-describing (carries its keys) so no positional alignment with settle-plans is needed."
        fvt-id:string
        score-entity-type:integer
        score-entity-id:string
        pre-deb:decimal
    )
    (defschema FVT|StakeSettleBundle
        @doc "Precomputed stake/unstake settle scope."
        settle-scores:[string]
        distinct-fvts:[string]
        settle-plans:[object{FVT|SettleScorePlan}]
        pre-nz-flags:[object{FVT|ScorePreNzFlag}]
        pre-member-debs:[object{FVT|MemberPreDeb}]
    )
    (defschema FVT|VacateFreeze
        @doc "Key = <FVT-ID>. True while a pool this FVT serves is mid-vacate — blocks collect + inject on the FVT \
            \ so the owner-forced vacate is not interfered with (stake/unstake are frozen pool-side via \
            \ PoolVacateInProgress). Set by AQP-VCT begin (XI_EnsureVacateBegun) on each of the vacating pool's \
            \ employed-score FVTs; cleared by VCT finalize. Read via UR_FVT|VacateFrozen (with-default-read false)."
        frozen:bool
    )
    (defschema FVT|SweepProgress
        @doc "Key = <Anchor-ID>. Cursor for the paginated defun+gate re-score sweep (CC_SweepBegin → \
            \ CCp_SweepRecomputeChunk*), the scalable twin of the fixed 2-step C_MTX|2|SweepRevokeAnchor defpact. \
            \ `total` = the recompute-set size captured at BEGIN (sweep-in-progress freeze holds URH_FvtPresentUsers \
            \ fixed across the batch's separate txs); `offset` = holders recomputed so far over the GLOBAL flattened \
            \ present set (present users concatenated across the boost-class's score-ids in order); `active` = a \
            \ sweep is open. The finalizing chunk (win-hi reaches total) unfreezes every affected pool + clears \
            \ active — completeness is ENFORCED (pools cannot unfreeze until offset reaches total). Read via \
            \ UR_FVT|SweepProgress / UR_FVT|SweepActive (with-default-read inactive)."
        total:integer
        offset:integer
        active:bool
    )
    (defschema FVT|AgencyFee
        @doc "Key = <FVT-ID> | <Score-Entity-ID>. DSA operator fee for a delegation member (the agency), mirrored \
            \ from DSA|Agency so the FVT inject settle can read it locally (FVT can't reach DSA). At inject the \
            \ member-slice is split: the delegator-facing index L_i advances by member-slice·(1−fee) (so ALL \
            \ stakers accrue net), and the whole member-slice·fee is credited DIRECTLY to the operator's pending — \
            \ giving the operator its own weighted share + the fee (effective weight own + fee·Σdelegators), \
            \ delegators (1−fee), conserved. The fee is never baked into a stored weight, so a fee change is O(1) \
            \ (it only reprices the NEXT inject). Set by DSA at open + A_SetAgencyFee."
        operator-konto:string
        fee-per-mille:integer
    )
    (defschema FVT|DsaOracleConfig
        @doc "Single GLOBAL row (key = FVT|DSA-ORACLE-KEY). The protocol-wide DSA external-oracle switch + validity \
            \ window, replacing the per-FVT oracle-on + the DSA_ORACLE_TTL constant. `external-oracle` = is external \
            \ oracling on at all: ON ⇒ a delegation member captures its weight only while its last oracle write is \
            \ fresher than `oracle-validity` seconds (no/stale entry ⇒ effective 0); OFF ⇒ oracling is bypassed \
            \ entirely and the stored capture-weight is trusted as-is. Read lazily (defaults: on=true, \
            \ validity=DSA_ORACLE_TTL) so no init is needed; written only by A_ToggleExternalOracle / \
            \ A_SetOracleValidity (DSA module admin) via the FVT XE_ setters."
        external-oracle:bool
        oracle-validity:integer
    )
    ;;{3.3}  tables
    ;;
    (deftable FVT|T:{FVT|Schema})                               ;; Key = <FVT-ID>
    (deftable FVT|T|ScoreEntityLink:{FVT|ScoreEntityLink})      ;; Key = <FVT-ID> | <Score-Entity-ID>
    (deftable FVT|T|MultipletFamily:{FVT|MultipletFamily})      ;; Key = <Multiplet-Family-ID>
    (deftable FVT|T|RPS|Global:{FVT|RPS|Global})                ;; Key = <FVT-ID> | <DPTF-ID>
    (deftable FVT|T|RPS|Member:{FVT|RPS|Member})                ;; Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
    (deftable FVT|T|RPS|User:{FVT|RPS|User})                    ;; Key = <User-ID> | <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
    (deftable FVT|T|RPS|Stream:{FVT|RPS|Stream})                ;; Key = <FVT-ID> | <DPTF-ID> | <position 1..49>
    (deftable FVT|T|MemberUserWeight:{FVT|MemberUserWeight})    ;; Key = <User-ID> | <FVT-ID> | <Score-Entity-ID>
    (deftable FVT|T|MemberVault:{FVT|MemberVault})              ;; Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
    (deftable FVT|T|UserPresence:{FVT|UserPresence})            ;; Key = <FVT-ID> | <Ouronet-ID>
    (deftable FVT|T|ForcedFixCount:{FVT|ForcedFixCount})        ;; Key = <FVT-ID> | <DPTF-ID> | <User-ID>
    (deftable FVT|T|VacateFreeze:{FVT|VacateFreeze})            ;; Key = <FVT-ID>
    (deftable FVT|T|SweepProgress:{FVT|SweepProgress})          ;; Key = <Anchor-ID>
    (deftable FVT|T|DsaOracleConfig:{FVT|DsaOracleConfig})      ;; Key = FVT|DSA-ORACLE-KEY (single global row)
    (deftable FVT|T|AgencyFee:{FVT|AgencyFee})                  ;; Key = <FVT-ID> | <Score-Entity-ID>
    (deftable FVT|T|QualitySplit:{FVT|QualitySplit})            ;; Key = <FVT-ID> | <DPTF-ID>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    (defcap FVT|XE>SWEEP-FIX (fvt-id:string)
        @doc "Forward (MTX-AQP MTX|n|C_Inject defpact): authorize a chunked deb-staleness FIX pass over an FVT's \
            \ stale stakers — NO fund movement (settle + refresh + mirror-resync only). Composes SECURE."
        (compose-capability (SECURE))
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap FVT|C>ISSUE-FVT
        (fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
        @doc "Issue one FVT|T row: autostake fvt-name, owner, class 0..2, farm common-denominator or vault/treasury \"|\". Composes SECURE for XI_IssueFvt."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV2} U|ATS)
                (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (fvt-id:string (ref-U|DALOS::UDC_Makeid fvt-name))
            )
            (enforce
                (fold (and) true
                    [
                        (>= fvt-class 0)
                        (<= fvt-class 2)
                        (not (URC_FvtExists fvt-id))
                    ]
                )
                "Invalid FVT issue: fvt-class must be 0..2 and fvt-name must be unused"
            )
            (if (= fvt-class 0)
                (enforce
                    (fold (and) true
                        [
                            (!= common-denominator BAR)
                            (!= common-denominator "|")
                        ]
                    )
                    "Farm FVT requires a full native DPTF common-denominator"
                )
                (enforce (= common-denominator "|") "Vault/Treasury FVT common-denominator must be |")
            )
            (if (= fvt-class 0)
                (ref-DPTF::UEV_id common-denominator)
                true
            )
            (ref-U|ATS::UEV_AutostakeIndex fvt-name)
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (ref-DALOS::UEV_EnforceAccountType owner-konto false)
            (compose-capability (SECURE))
        )
    )
    (defcap FVT|C>ROTATE-OWNERSHIP-FVT (fvt-id:string new-owner-konto:string)
        @doc "Rotate FVT owner-konto: current owner, can-change-owner true, distinct new standard account. Composes SECURE."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (owner-now:string (UR_FVT|OwnerKonto fvt-id))
                (can-change-owner:bool (UR_FVT|CanChangeOwner fvt-id))
            )
            (enforce
                (and can-change-owner (!= new-owner-konto owner-now))
                "FVT owner rotation requires can-change-owner true and a distinct new owner-konto"
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-now)
            (ref-DALOS::UEV_EnforceAccountType new-owner-konto false)
            (compose-capability (SECURE))
        )
    )
    (defcap FVT|C>CONTROL-FVT (fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Update FVT can-upgrade and can-change-owner: owner ownership and current can-upgrade true. Composes SECURE."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                (can-upgrade:bool (UR_FVT|CanUpgrade fvt-id))
            )
            (enforce can-upgrade "FVT control update requires can-upgrade true")
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (compose-capability (SECURE))
        )
    )
    (defcap FVT|C>SET-COMMON-DENOMINATOR (fvt-id:string common-denominator:string)
        @doc "Farm-only: set common-denominator before any ScoreEntityLink rows. Owner + can-upgrade. Composes SECURE."
        @event
        (UEV_SetCommonDenominatorContext fvt-id common-denominator)
        (compose-capability (SECURE))
    )
    (defcap FVT|C>SET-MOSAIC (fvt-id:string mosaic:bool)
        @doc "Toggle mosaic membership policy when FVT has zero ScoreEntityLink rows. Owner + can-upgrade. Composes SECURE."
        @event
        (UEV_SetMosaicContext fvt-id mosaic)
        (compose-capability (SECURE))
    )
    (defcap FVT|C>ADD-SCORE-ENTITY
        (fvt-id:string score-entity-type:integer score-entity-id:string swpair:string ghost-weight:decimal)
        @doc "Admit score (type 1) or triplet (type 3) via ScoreEntityLink. Composes SECURE."
        @event
        (UEV_AddScoreEntityContext fvt-id score-entity-type score-entity-id swpair ghost-weight)
        (compose-capability (SECURE))
    )
    (defcap FVT|C>ISSUE-MULTIPLET-FAMILY
        (
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
        )
        @doc "Issue one FVT|T|MultipletFamily reward ladder. Distinct tokens and ATS pairs; family id unused. Composes SECURE."
        @event
        (UEV_IssueMultipletFamilyContext token-0-id token-1-id token-2-id ats-0-1-id ats-1-2-id)
        (compose-capability (SECURE))
    )
    (defcap FVT|C>TOGGLE-SCORE-ENTITY-LINK
        (fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
        @doc "Toggle ScoreEntityLink.enabled; farm adjusts S. FVT owner. Composes SECURE."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_FvtScoreEntityLinkRowExists fvt-id score-entity-id) "ScoreEntityLink row must exist")
            (enforce (= score-entity-type (UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id)) "score-entity-type mismatch")
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (compose-capability (SECURE))
        )
    )
    (defcap FVT|C>ADD-REWARD-LINK
        (fvt-id:string reward-dptf-id:string segmentation:bool reward-kind:string multiplet-family-id:string)
        @doc "Insert FVT|T|RPS|Global with reward-enabled true. FVT owner; issued reward DPTF. Composes SECURE."
        @event
        (UEV_AddRewardLinkContext fvt-id reward-dptf-id reward-kind multiplet-family-id)
        (compose-capability (SECURE))
    )
    (defcap FVT|C>SET-QUALITY-SPLIT
        (fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
        @doc "Set a MULTIPLET_BASE reward's quality-split mode + heterogeneous matrix. FVT owner. Composes SECURE."
        @event
        (UEV_QualitySplitContext fvt-id reward-dptf-id mode bronze-split silver-split gold-split)
        (compose-capability (SECURE))
    )
    (defcap FVT|C>SET-SPLIT-MODE (fvt-id:string split-mode:string)
        @doc "Set the farm reward-split mode (D1-G2): SPLIT|STAKED (participation) | SPLIT|TVL (pool-size). Farm \
            \ (class 0) only; FVT owner; FREELY mutable (no cooldown) — a change re-weights only FUTURE injects \
            \ (RPS is checkpoint-based, past rewards untouched). Composes SECURE."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
            )
            ;; 1] farm-only + valid mode value (two boolean conditions → one enforce)
            (enforce
                (and (= (UR_FVT|FvtClass fvt-id) 0)
                     (or (= split-mode CT_SPLIT_MODE_STAKED) (= split-mode CT_SPLIT_MODE_TVL)))
                "Split-mode: farm (class 0) only, value must be SPLIT|STAKED or SPLIT|TVL")
            ;; 2] owner authorization
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (compose-capability (SECURE))
        )
    )
    (defcap FVT|C>TOGGLE-REWARD-LINK (fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Toggle RPS|Global.reward-enabled; ±1 enabled-reward-count on flip. FVT owner. Composes SECURE."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) "Reward link row must exist")
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (compose-capability (SECURE))
        )
    )
    (defcap FVT|C>INJECT
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Inject reward DPTF into FVT RPS (UrStoa URV|INJECT). Farm: S>0; vault/treasury: total-deb-score>0; reward-enabled. \
            \ Composes P|SECURE-CALLER + P|FVT|REMOTE-GOV for TFT custody to AQP|SC_NAME."
        @event
        (UEV_InjectContext patron fvt-id reward-dptf-id amount)
        (compose-capability (P|SECURE-CALLER))
        (compose-capability (P|FVT|REMOTE-GOV))
    )
    (defcap FVT|C>INJECT-STREAM
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
        @doc "Inject a reward DPTF as a TIME-STREAM (linear vesting over `duration` seconds). Same reward context \
            \ as an instant inject (UEV_InjectContext: not vacate-frozen, reward-enabled, patron/amount valid) plus \
            \ the count-independent stream-param guard (UEV_StreamParams: duration bounds + min rate). The slot-cap \
            \ (Elite-tier concurrent-stream limit on the FVT owner konto) is enforced in XI_FvtAddStream AFTER the \
            \ drip. Composes the same P|SECURE-CALLER + P|FVT|REMOTE-GOV as an inject (TFT custody to AQP|SC_NAME)."
        @event
        (UEV_InjectContext patron fvt-id reward-dptf-id amount)
        (UEV_StreamParams reward-dptf-id amount duration)
        (compose-capability (P|SECURE-CALLER))
        (compose-capability (P|FVT|REMOTE-GOV))
    )
    (defcap FVT|C>INJECT-FIX (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "Protects a paginated enforced-fresh inject FIX chunk (CCp_InjectFixChunk) — the scalable prelude to \
            \ CC_InjectFinalize, for stale sets exceeding one tx. Validates the SAME reward context as an inject \
            \ (not vacate-frozen, reward link row exists + enabled) minus the amount, so a fix pass is always tied \
            \ to a real reward link (the fix force-refreshes stale stakers + records the 2e penalty, exactly as \
            \ the C_MTX|2|Inject defpact does). `chunk` is bounded by the loose INJECT-FIX-CHUNK-MAX backstop (the \
            \ UI sizes it by simulation; the node gas meter is the real ceiling). Composes P|SECURE-CALLER for the \
            \ intra-module fix + the cross-module XE_RefreshUserScoreDeb into AQP-SCORE. `patron` retained for \
            \ symmetry / the event."
        @event
        (enforce (not (UR_FVT|VacateFrozen fvt-id)) "FVT is frozen: a pool it serves is mid-vacate")
        (enforce (and (URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) (UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id))
            "Reward link row must exist and be enabled for a fix pass")
        (enforce (and (> chunk 0) (<= chunk INJECT-FIX-CHUNK-MAX))
            "Inject-fix chunk out of range — the UI sizes it by simulation, the gas meter is the real ceiling")
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap FVT|C>UNSTALE-ALL (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "Protects the OWNER-run mass deb-unstale (CCp_UnstaleAll): the FVT entity owner force-refreshes up to \
            \ `chunk` currently-stale present stakers to make the entity INJECTION-READY, WITHOUT injecting. Uses \
            \ the SAME penalized fix as an inject's fix-phase (XI_FixUserFvtDebPenalizedIn records the 2e forced-fix \
            \ count on (fvt, reward-dptf, user) → the user reimburses it in non-discountable IGNIS at his next \
            \ collect of this lane), so a standalone prep and a real inject tag stale users identically. Validates \
            \ the SAME reward context as an inject (not vacate-frozen, reward link row exists + enabled) minus the \
            \ amount, plus the `chunk` bound. Unlike the permissionless inject-fix (part of a billed inject flow), \
            \ this standalone op is OWNER-GATED — only the FVT owner may pre-unstale their own entity. Composes \
            \ P|SECURE-CALLER for the intra-module fix + the cross-module XE_RefreshUserScoreDeb into AQP-SCORE."
        @event
        (let ((ref-DALOS:module{OuronetDalosV1} DALOS))
            (ref-DALOS::CAP_EnforceAccountOwnership (UR_FVT|OwnerKonto fvt-id)))
        (enforce (not (UR_FVT|VacateFrozen fvt-id)) "FVT is frozen: a pool it serves is mid-vacate")
        (enforce (and (URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) (UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id))
            "Reward link row must exist and be enabled for an unstale pass")
        (enforce (and (> chunk 0) (<= chunk INJECT-FIX-CHUNK-MAX))
            "Unstale chunk out of range — the UI sizes it by simulation, the gas meter is the real ceiling")
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap FVT|C>SWEEP-REVOKE (patron:string anchor-id:string)
        @doc "Protects the single-tx re-score sweep (CC_SweepRevokeAnchor). Composes P|SECURE-CALLER so SECURE is \
            \ granted for the intra-module recompute (XI_*) AND FVT's registered SECURE guard is satisfied for the \
            \ cross-module XE calls into AQP-ANK (aggregate refold + swept anchor removal) and AQP-POOL (freeze) — \
            \ FVT is in both IMPs (P|A_Define). The anchor owner (= anchored-asset owner) is enforced inside \
            \ ANK|XE>SWEEP-REVOKE."
        @event
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap FVT|C>COLLECT
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Collect accrued rewards for patron on one score-entity × reward DPTF. Composes P|SECURE-CALLER + P|FVT|REMOTE-GOV."
        @event
        (UEV_CollectContext patron fvt-id score-entity-type score-entity-id reward-dptf-id)
        (compose-capability (P|SECURE-CALLER))
        (compose-capability (P|FVT|REMOTE-GOV))
    )
    (defcap FVT|XE>SWEEP-BRACKET (anchor-id:string)
        @doc "Forward (paginated MTX|n|C_SweepRevokeAnchor defpact): authorize the sweep BRACKET — freeze/unfreeze \
            \ every affected pool and the one-shot swept-revoke of the anchor. Composes P|SECURE-CALLER so FVT's \
            \ SECURE guard is satisfied for the cross-module XE calls into AQP-POOL (freeze) and AQP-ANK (revoke); \
            \ the anchor owner (= anchored-asset owner) is enforced inside ANK|XE>SWEEP-REVOKE."
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap FVT|XE>ADMIT-DELEGATION (fvt-id:string triplet-id:string operator:string)
        @doc "DSA: authorize admitting an OPERATOR-owned triplet as a delegation agency member on a class-0 DSA \
            \ vault FVT — vault-like (swpair \"|\", ghost 0; its inject weight is capture, not ghost-tvl). Runs the \
            \ STRUCTURAL subset of the normal triplet admission (triplet issued, category matches class, no \
            \ pre-existing link, silver has an aqpool, all three fvt-links BAR) but with `silver-owner == operator` \
            \ + the operator's account ownership, and SKIPS the LP-farm rules (swpair/lp-denominator/ghost-weight) \
            \ — a delegation member does not use ghost-tvl. Isolated from C_AddScoreEntity's admission (never \
            \ weakened). Composes SECURE for the XE_CreateFvtLink + XI_AddScoreEntity writes."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (bronze-id:string (ref-SCR::UR_SCR|TripletBronzeScoreId triplet-id))
                (silver-id:string (ref-SCR::UR_SCR|TripletSilverScoreId triplet-id))
                (golden-id:string (ref-SCR::UR_SCR|TripletGoldenScoreId triplet-id))
                (silver-owner:string (ref-SCR::UR_SCR|ScoreOwnerKonto silver-id))
                (silver-aqpool:string (ref-SCR::UR_SCR|ScoreAqpoolLink silver-id))
            )
            (enforce (ref-SCR::URC_TripletExists triplet-id) "Triplet must be issued in AQP-SCORE")
            ;; NOTE: the triplet-category↔fvt-class check is intentionally SKIPPED for delegation — a DSA agency is
            ;; an SF/quintessence triplet admitted to a class-0 FVT purely to ride the farm-split code; it does not
            ;; fit the LP class model (see DSA-DELEGATED-STAKING-DESIGN.md §2). All class/LP rules are bypassed here.
            (enforce
                (fold (and) true
                    [(= silver-owner operator)
                     (not (URC_FvtScoreEntityLinkRowExists fvt-id triplet-id))
                     (!= silver-aqpool BAR)
                     (= (ref-SCR::UR_SCR|ScoreFvtLink bronze-id) BAR)
                     (= (ref-SCR::UR_SCR|ScoreFvtLink silver-id) BAR)
                     (= (ref-SCR::UR_SCR|ScoreFvtLink golden-id) BAR)])
                "Invalid delegation admission: operator ownership, existing link, silver aqpool, or fvt-links")
            (ref-DALOS::CAP_EnforceAccountOwnership operator)
            (compose-capability (SECURE))
        )
    )
    (defcap FVT|XE>DISPOSE-ROYALTY (fvt-id:string reward-dptf-id:string)
        @doc "DSA royalty disposal: authorize moving the whole royalty pool (reward-dptf) OUT of the AQP pool-vault \
            \ custody (AQP|SC_NAME) + zeroing royalty-rewards. Enforces a non-empty pool. Composes P|SECURE-CALLER + \
            \ P|FVT|REMOTE-GOV — the AQP custody-governor authority for the TFT leg out of AQP|SC_NAME (same as \
            \ FVT|C>INJECT). Owner authorization is enforced upstream in the DSA A_ shell."
        @event
        (enforce (> (UR_FVT-RG|RoyaltyRewards fvt-id reward-dptf-id) 0.0) "No royalty to dispose")
        (compose-capability (P|SECURE-CALLER))
        (compose-capability (P|FVT|REMOTE-GOV))
    )
    (defcap FVT|C>SWEEP-DRAIN (patron:string anchor-id:string chunk:integer)
        @doc "Protects a paginated re-score sweep CHUNK (CCp_SweepRecomputeChunk). The sweep was authorized + the \
            \ anchor swept-revoked at CC_SweepBegin (owner enforced in ANK|XE>SWEEP-REVOKE); a chunk only COMPLETES \
            \ the already-committed recompute under the freeze, so it re-checks the cursor is ACTIVE (honest \
            \ completion — re-enforcing owner per chunk is unnecessary; premature unfreeze is impossible because \
            \ the body unfreezes only when offset reaches total). `chunk` is bounded by the loose gas backstop \
            \ SWEEP-CHUNK-MAX — the UI sizes the real chunk by simulation, the node gas meter is the real \
            \ enforcement. Composes P|SECURE-CALLER for the intra-module recompute + cross-module XE calls."
        @event
        (enforce (UR_FVT|SweepActive anchor-id) "No active sweep for this anchor")
        (enforce (and (> chunk 0) (<= chunk SWEEP-CHUNK-MAX))
            "Sweep chunk out of range — the UI sizes it by simulation, the gas meter is the real ceiling")
        (compose-capability (P|SECURE-CALLER))
    )
    (defcap FVT|C>UNSTALE-MY-SCORES (patron:string)
        @doc "User SELF-SERVICE deb-unstale (CC_UnstaleMyScores): the caller refreshes THEIR OWN stale scores \
            \ across the listed FVTs — settle pending at the old deb, refresh the score deb to the live Elite-DEB, \
            \ resync the FVT total-deb mirror — NON-penalized (contrast the inject's forced fix, which bills the \
            \ 2e penalty; self-service is deliberately the cheaper path so users proactively unstale). Auth = \
            \ account ownership of `patron`: you may only unstale your OWN scores, and refreshing your deb to the \
            \ live value is always safe (no fund movement — pending is banked, not paid). Composes P|SECURE-CALLER \
            \ for the intra-module fix + the cross-module XE_RefreshUserScoreDeb into AQP-SCORE."
        @event
        (let ((ref-DALOS:module{OuronetDalosV1} DALOS))
            (ref-DALOS::CAP_EnforceAccountOwnership patron))
        (compose-capability (P|SECURE-CALLER))
    )
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
                (stake-admission-ok:bool (if direction (ref-AQP::URC_PoolStakeAdmissionOk pool-id) (ref-AQP::URC_PoolUnstakeAdmissionOk pool-id)))
                (dptf-pool-ok:bool (ref-AQP::URC_StakeTrueFungibleDptfMatchesPool pool-id dptf-id))
                (fvt-ready:bool (if direction (URC_PoolEmployedScoresFvtStakeReady pool-id) true))
            )
            ;;1] pool-id
            ;;1a] pool-id must refer to issued AQP|T|Pool row — implicit (AQP-POOL URC_* reads pool-id key)
            ;;1b] aqp-class must be TF-stakeable (0 = LP, 1 = DPTF) — HERE
            (enforce pool-class-ok "Invalid pool-id: TF stake requires aqp-class 0 or 1")
            ;;1c] stake direction: stake-enabled + ≥1 employed score — HERE
            (enforce stake-admission-ok "Invalid pool-id: pool stake disabled or has no employed scores")
            ;;
            ;;4] dptf-id
            ;;4a] dptf-id must not be R| reserved leg — HERE
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
            ;;7] FVT reward pipeline (phase 2.1 / 2.4 — stake direction only)
            ;;7a] every employed score: fvt-link ≠ BAR, FVT issued, ScoreEntityLink enabled, ≥1 enabled reward DPTF — HERE
            (if direction
                (enforce fvt-ready "Invalid FVT reward pipeline: employed score missing enabled FVT ScoreEntityLink or reward DPTF")
                true
            )
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
            (UEV_TrueFungibleStakeNotReserved dptf-id)
            ;;
            ;;8] transfer / custody (phase 1 — not re-validated here)
            ;;8a] owner signer proof — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (CAP_StakeOwner)
            ;;8b] TFT IMC + AQP|SC_NAME vault governor — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (P|AQP|CALLER, AQP|GOV)
            ;;
            ;;9] admission-time only (not re-checked at stake)
            ;;9a] score LP denominator vs pool pair — C_AddScore admission
            ;;9b] FVT common-denominator vs member scores — C_AddScoreEntity admission
            ;;9c] aqpool-link slot assignment — C_AddScore / C_RevokeScore
            ;;
            ;;--- UrStoa canonical phases (see map above CC_TrueFungibleStakeFlow) ---
            ;; PHASE 1   1.1–1.3 AQP-POOL custody
            ;; PHASE 2   FVT::XI_RpsPreScore
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
                (stake-admission-ok:bool (if direction (ref-AQP::URC_PoolStakeAdmissionOk pool-id) (ref-AQP::URC_PoolUnstakeAdmissionOk pool-id)))
                (fvt-ready:bool (if direction (URC_PoolEmployedScoresFvtStakeReady pool-id) true))
                (l-n:integer (length nonces))
                (l-a:integer (length nonce-amounts))
            )
            ;;1] pool-id — stake direction: stake-enabled + ≥1 employed score
            (enforce stake-admission-ok "Invalid pool-id: pool stake disabled or has no employed scores")
            ;;3] beneficiary-id — M5: caller-supplied and authoritative BOTH directions (self OR foreign). The real
            ;;   (owner, beneficiary) tracker row is written on stake and removed on unstake; sufficiency for that exact
            ;;   row is enforced in AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY. No BAR sentinel / self-key derivation any more.
            ;;4] dpof-id — issued DPOF; pool leg match in AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY
            ;;5] nonces / nonce-amounts — equal positive length. L1 #16: no "amount == nonce supply" check —
            ;;   DPOF::C_Transfer moves WHOLE nonces (ignores amounts) and callers source amounts from
            ;;   UR_NoncesSupplies, so whole-nonce is a structural token-layer invariant, not a cap-level check.
            (enforce
                (fold (and) true [(> l-n 0) (= l-n l-a)])
                "Invalid nonces / nonce-amounts: equal positive length required"
            )
            ;;6] direction — stake/unstake; unstake sufficiency in AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY
            ;;7] FVT reward pipeline — stake direction only
            (if direction
                (enforce fvt-ready "Invalid FVT reward pipeline: employed score missing enabled FVT ScoreEntityLink or reward DPTF")
                true
            )
            ;;2] owner-id — activated account; signer proof in AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY
            (UEV_TrueFungibleStakeOwnerAccount owner-id)
            ;;3a/3b] beneficiary must exist + be a standard account — BOTH directions (mirror TF flow cap).
            (UEV_TrueFungibleStakeBeneficiaryAccount beneficiary-id)
            ;;--- UrStoa canonical phases (no 1.3 / 3.x on OF — reserved no-op) ---
            ;; PHASE 1   1.1–1.2 AQP-POOL; 1.3 no-op
            ;; PHASE 2   FVT::XI_RpsPreScore
            ;; PHASE 3   3.1–3.3 no-op
            ;; PHASE 4   SCR::XE_ApplyOrtoFungibleStakeDelta
            ;; PHASE 5   5.1 unclaimed; 5.2 checkpoint
            (compose-capability (SECURE))
        )
    )
    (defcap FVT|C>COLLECTABLE-STAKE-FLOW
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
        @doc "DPDC collectable stake/unstake recipe. son=true DPSF (class-3 pool); son=false DPNF (class-4 pool). \
            \ Phase 1 custody: AQP|XE>COLLECTABLE-POOL-CUSTODY."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (stake-admission-ok:bool (if direction (ref-AQP::URC_PoolStakeAdmissionOk pool-id) (ref-AQP::URC_PoolUnstakeAdmissionOk pool-id)))
                (fvt-ready:bool (if direction (URC_PoolEmployedScoresFvtStakeReady pool-id) true))
                (class-ok:bool (ref-AQP::URC_StakeCollectablePoolClassOk pool-id son))
                (collectable-ok:bool (ref-AQP::URC_StakeCollectableMatchesPool pool-id collectable-id))
                (l-n:integer (length nonces))
                (l-a:integer (length nonce-amounts))
            )
            (enforce stake-admission-ok "Invalid pool-id: pool stake disabled or has no employed scores")
            (enforce class-ok "Invalid pool-id: collectable son does not match pool aqp-class")
            (enforce collectable-ok "Invalid collectable-id: leg does not match pool canonical asset")
            ;; M5: beneficiary-id caller-supplied and authoritative BOTH directions (self OR foreign). The real
            ;; (owner, beneficiary) tracker + Ben rollup rows are written on stake and removed on unstake; sufficiency
            ;; for that exact row is enforced in AQP|XE>COLLECTABLE-POOL-CUSTODY. No BAR sentinel / self-key derivation.
            (enforce
                (fold (and) true [(> l-n 0) (= l-n l-a)])
                "Invalid nonces / nonce-amounts: equal positive length required"
            )
            (if direction
                (enforce fvt-ready "Invalid FVT reward pipeline: employed score missing enabled FVT ScoreEntityLink or reward DPTF")
                true
            )
            (UEV_TrueFungibleStakeOwnerAccount owner-id)
            ;; beneficiary must exist + be a standard account — BOTH directions (mirror TF flow cap).
            (UEV_TrueFungibleStakeBeneficiaryAccount beneficiary-id)
            (compose-capability (SECURE))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Bar ()
        @doc "Returns CT_BAR constant."
        (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR))
    )
    (defun CT_AqpScName:string
        ()
        @doc "Resolves AQP|SC_NAME from canonical AQP-ANK via interface ref."
        (let ((ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)) (ref-ANK::GOV|AQP|SC_NAME))
    )
    ;;
    ;; [UDC] construct
    ;;
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
            member-link-count:integer
            mosaic:bool
            membership-mode:string
            oracle-on:bool
            split-mode:string
            fvt-id:string
        )
        @doc "Core constructor for object{FVT|Schema}. oracle-on (DSA node/uptime oracle toggle) passes through — \
            \ false for every non-DSA FVT. split-mode = farm reward-split (SPLIT|STAKED default | SPLIT|TVL)."
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
        ,"member-link-count"        : member-link-count
        ,"mosaic"                   : mosaic
        ,"membership-mode"          : membership-mode
        ,"oracle-on"                : oracle-on
        ,"split-mode"               : split-mode
        ,"fvt-id"                   : fvt-id}
    )
    (defun UDC_FVT|ScoreEntityLink:object{FVT|ScoreEntityLink}
        (
            score-entity-type:integer
            enabled:bool
            swpair:string
            ghost-tvl-weight:decimal
            total-lane-weight:decimal
            delegation:bool
            capture-units:decimal
            capture-weight:decimal
            oracle-ts:time
            fvt-id:string
            score-entity-id:string
        )
        @doc "Core constructor for object{FVT|ScoreEntityLink}. DSA fields (delegation / capture-units / \
            \ capture-weight / oracle-ts) pass through faithfully — a normal member passes \
            \ false / 0.0 / 0.0 / STREAM_EPOCH; DSA passes an agency's live capture."
        {"score-entity-type"        : score-entity-type
        ,"enabled"                  : enabled
        ,"swpair"                   : swpair
        ,"ghost-tvl-weight"         : ghost-tvl-weight
        ,"total-lane-weight"        : total-lane-weight
        ,"delegation"               : delegation
        ,"capture-units"            : capture-units
        ,"capture-weight"           : capture-weight
        ,"oracle-ts"                : oracle-ts
        ,"fvt-id"                   : fvt-id
        ,"score-entity-id"          : score-entity-id}
    )
    (defun UDC_FVT|RPS|Global:object{FVT|RPS|Global}
        (
            reward-enabled:bool
            current-rps:decimal
            available-rewards:decimal
            unclaimed-count:integer
            zombie-rewards:decimal
            segmentation:bool
            reward-kind:string
            multiplet-family-id:string
            stream-count:integer
            stream-last-release:time
            stream-unreleased:decimal
            royalty-rewards:decimal
            fvt-id:string
            dptf-id:string
        )
        @doc "Core constructor for object{FVT|RPS|Global}. Stream-ledger fields (stream-count / \
            \ stream-last-release / stream-unreleased) + the DSA royalty-rewards pool pass through faithfully; \
            \ true inserts seed them 0 / STREAM_EPOCH / 0.0 / 0.0 (a fresh lane has no stream, no royalty)."
        {"reward-enabled"       : reward-enabled
        ,"current-rps"          : current-rps
        ,"available-rewards"    : available-rewards
        ,"unclaimed-count"      : unclaimed-count
        ,"zombie-rewards"       : zombie-rewards
        ,"segmentation"         : segmentation
        ,"reward-kind"          : reward-kind
        ,"multiplet-family-id"    : multiplet-family-id
        ,"stream-count"         : stream-count
        ,"stream-last-release"  : stream-last-release
        ,"stream-unreleased"    : stream-unreleased
        ,"royalty-rewards"      : royalty-rewards
        ,"fvt-id"               : fvt-id
        ,"dptf-id"              : dptf-id}
    )
    (defun UDC_FVT|RPS|Stream:object{FVT|RPS|Stream}
        (
            rate:decimal
            finish:time
            amount:decimal
            released:decimal
            fvt-id:string
            dptf-id:string
            position:integer
        )
        @doc "Core constructor for object{FVT|RPS|Stream} — one active linear-release stream position."
        {"rate"             : rate
        ,"finish"           : finish
        ,"amount"           : amount
        ,"released"         : released
        ,"fvt-id"           : fvt-id
        ,"dptf-id"          : dptf-id
        ,"position"         : position}
    )
    (defun UDC_FVT|MultipletFamily:object{FVT|MultipletFamily}
        (
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
            rank:integer
            active:bool
            multiplet-family-id:string
        )
        @doc "Core constructor for object{FVT|MultipletFamily}."
        {"token-0-id"           : token-0-id
        ,"token-1-id"           : token-1-id
        ,"token-2-id"           : token-2-id
        ,"ats-0-1-id"           : ats-0-1-id
        ,"ats-1-2-id"           : ats-1-2-id
        ,"rank"                 : rank
        ,"active"               : active
        ,"multiplet-family-id"  : multiplet-family-id}
    )
    (defun UDC_FVT|RPS|Member:object{FVT|RPS|Member}
        (
            last-farm-rps-g:decimal
            member-deb-rps:decimal
            pending-member-rewards:decimal
            fvt-id:string
            score-entity-id:string
            dptf-id:string
        )
        @doc "Core constructor for object{FVT|RPS|Member}."
        {"last-farm-rps-g"          : last-farm-rps-g
        ,"member-deb-rps"           : member-deb-rps
        ,"pending-member-rewards"   : pending-member-rewards
        ,"fvt-id"                   : fvt-id
        ,"score-entity-id"          : score-entity-id
        ,"dptf-id"                  : dptf-id}
    )
    (defun UDC_FVT|RPS|User:object{FVT|RPS|User}
        (
            last-rps:decimal
            pending-rewards:decimal
            user-id:string
            fvt-id:string
            score-entity-id:string
            dptf-id:string
        )
        @doc "Core constructor for object{FVT|RPS|User}."
        {"last-rps"         : last-rps
        ,"pending-rewards"  : pending-rewards
        ,"user-id"          : user-id
        ,"fvt-id"           : fvt-id
        ,"score-entity-id"  : score-entity-id
        ,"dptf-id"          : dptf-id}
    )
    ;; --- Phase 2.1 settle · ephemeral (no deftable / no UR) ---
    (defun UDC_FVT|SettleFvtRewards:object{FVT|SettleFvtRewards}
        (fvt-id:string reward-dptf-ids:[string])
        @doc "Constructor for object{FVT|SettleFvtRewards} — one URH_FVT|SettleFvtRewardBundle entry."
        {"fvt-id"           : fvt-id
        ,"reward-dptf-ids"  : reward-dptf-ids}
    )
    (defun UDC_FVT|SettleScorePlan:object{FVT|SettleScorePlan}
        (score-entity-type:integer score-entity-id:string fvt-id:string reward-dptf-ids:[string])
        @doc "Constructor for object{FVT|SettleScorePlan} — one URC_SettleScorePlanRows entry."
        {"score-entity-type" : score-entity-type
        ,"score-entity-id"   : score-entity-id
        ,"fvt-id"            : fvt-id
        ,"reward-dptf-ids"   : reward-dptf-ids}
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
            pre-member-debs:[object{FVT|MemberPreDeb}]
        )
        @doc "Constructor for object{FVT|StakeSettleBundle} — shared phase 2.1 / 2.35 / 2.4 settle scope."
        {"settle-scores"    : settle-scores
        ,"distinct-fvts"    : distinct-fvts
        ,"settle-plans"     : settle-plans
        ,"pre-nz-flags"     : pre-nz-flags
        ,"pre-member-debs"  : pre-member-debs}
    )
    ;;{5.2}  Compute [UC]
    ;; [UC]  compute
    (defun UCk_ScoreEntityLink:string (fvt-id:string score-entity-id:string)
        @doc "Composite key for FVT|T|ScoreEntityLink: fvt-id | score-entity-id."
        (concat [fvt-id BAR score-entity-id])
    )
    (defun UCk_RpsGlobal:string (fvt-id:string dptf-id:string)
        @doc "Composite key for FVT|T|RPS|Global: fvt-id | dptf-id."
        (concat [fvt-id BAR dptf-id])
    )
    (defun UCk_RpsMember:string (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Composite key for FVT|T|RPS|Member: fvt-id | score-entity-id | dptf-id."
        (concat [fvt-id BAR score-entity-id BAR dptf-id])
    )
    (defun UCk_RpsUser:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Composite key for FVT|T|RPS|User: user-id | fvt-id | score-entity-id | dptf-id."
        (concat [user-id BAR fvt-id BAR score-entity-id BAR dptf-id])
    )
    (defun UCk_MemberUserWeight:string (user-id:string fvt-id:string score-entity-id:string)
        @doc "Composite key for FVT|T|MemberUserWeight: user-id | fvt-id | score-entity-id."
        (concat [user-id BAR fvt-id BAR score-entity-id])
    )
    (defun UCk_UserPresence:string (fvt-id:string ouronet-account:string)
        @doc "Composite key for FVT|T|UserPresence: fvt-id | ouronet-id."
        (concat [fvt-id BAR ouronet-account])
    )
    (defun UCk_ForcedFixCount:string (fvt-id:string dptf-id:string user-id:string)
        @doc "Composite key for FVT|T|ForcedFixCount: fvt-id | dptf-id | user-id."
        (concat [fvt-id BAR dptf-id BAR user-id])
    )
    (defun UCk_MultipletFamily:string (token-0-id:string token-1-id:string token-2-id:string)
        @doc "Composite key for FVT|T|MultipletFamily: F | token-0 | token-1 | token-2."
        (concat ["F" BAR token-0-id BAR token-1-id BAR token-2-id])
    )
    (defun UCk_RpsStream:string (fvt-id:string dptf-id:string position:integer)
        @doc "Composite key for FVT|T|RPS|Stream: fvt-id | dptf-id | position."
        (concat [fvt-id BAR dptf-id BAR (int-to-str 10 position)])
    )
    (defun UC_ComputeInjectGainedRps:decimal (reward-amount:decimal denominator:decimal)
        @doc "Pure: Tier-2 G increment for one inject — floor(R / S, CT_FVT_RPS_PREC). UrStoa ≡ floor(stoa/S, STOA_PREC)."
        (if (<= denominator 0.0)
            0.0
            (floor (/ reward-amount denominator) CT_FVT_RPS_PREC)
        )
    )
    (defun UC_EmptyOc:object{IgnisCollectorV1.OutputCumulator} ()
        @doc "Empty OutputCumulator for write-only inject/collect phase slots."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    (defun UC_PerMilleRow:bool (row:[integer])
        @doc "True when `row` is exactly 3 non-negative integers summing to 1000 (a heterogeneous lane split)."
        (and
            (= (length row) 3)
            (and
                (fold (and) true (map (lambda (x:integer) (>= x 0)) row))
                (= (fold (+) 0 row) 1000)
            )
        )
    )
    ;; [URCi]   multi-leg STAKE/UNSTAKE flow ifp readers — relocated from AQP-INFO (byte-identical ifp sums).
    ;;   Mirror CC_*StakeFlow leg-for-leg; every leg gated by the virtual-gas toggle so toggle-on -> 0.
    ;;   Tier gates below reproduce the UsagePrice tier behind URC_IsVirtualGasZero);
    ;;   AQP-VCT's vacate readers reach them + the two score-delta sums cross-module. Leg map:
    ;;   memories/2026-08-27-aqp-info-final17-costmap.md
    (defun UC_GasPrice:decimal (full-price:decimal trigger:bool)
        @doc "Full price when live billing is on (trigger=false); 0.0 when the gas toggle zeroes it."
        (if trigger 0.0 full-price)
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [UR]  read
    ;; FVT|T|MemberVault  Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>  (Tier-1 dust sweep, M1/#10)
    (defun UR_FVT-MV|AvailableRewards:decimal (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Member mini-vault available-rewards (Tier-1 sweep); 0.0 when absent."
        (with-default-read FVT|T|MemberVault (UCk_RpsMember fvt-id score-entity-id dptf-id)
            {"available-rewards": 0.0} {"available-rewards" := ar} ar)
    )
    (defun UR_FVT-MV|UnclaimedCount:integer (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Member mini-vault unclaimed-count (users with a live claim); 0 when absent."
        (with-default-read FVT|T|MemberVault (UCk_RpsMember fvt-id score-entity-id dptf-id)
            {"unclaimed-count": 0} {"unclaimed-count" := uc} uc)
    )
    ;;
    (defun UR_FVT-UP|IsPresent:bool (fvt-id:string ouronet-account:string)
        @doc "True while this user holds a live position in ≥1 of the FVT's score-entities; false/absent otherwise."
        (with-default-read FVT|T|UserPresence (UCk_UserPresence fvt-id ouronet-account)
            {"is-present": false} {"is-present" := p} p)
    )
    ;;
    (defun UR_FVT-FFC|Count:integer (fvt-id:string dptf-id:string user-id:string)
        @doc "Inject-forced deb-fix count on this (fvt, reward lane, user) since the user last collected it; 0 absent."
        (with-default-read FVT|T|ForcedFixCount (UCk_ForcedFixCount fvt-id dptf-id user-id)
            {"count": 0} {"count" := c} c)
    )
    ;;
    ;; Reads follow schema order: (1) FVT|Schema (2) ScoreEntityLink (3) MultipletFamily (4) RPS|Global (5) RPS|Member (6) RPS|User
    ;;
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
    (defun UR_FVT|VacateFrozen:bool (fvt-id:string)
        @doc "True when the FVT is frozen for a pool vacate (blocks collect + inject). Default false (unset)."
        (with-default-read FVT|T|VacateFreeze fvt-id
            {"frozen": false}
            {"frozen":= frozen}
            frozen
        )
    )
    (defun UR_FVT|SweepProgress:object{FVT|SweepProgress} (anchor-id:string)
        @doc "The paginated re-score sweep cursor for anchor-id; defaults to an inactive empty cursor when no \
            \ sweep is open. Module-only (returns a module schema)."
        (with-default-read FVT|T|SweepProgress anchor-id
            {"total": 0, "offset": 0, "active": false}
            {"total" := t, "offset" := o, "active" := a}
            {"total": t, "offset": o, "active": a}
        )
    )
    (defun UR_FVT|SweepActive:bool (anchor-id:string)
        @doc "True while a paginated re-score sweep is open for anchor-id (gates CCp_SweepRecomputeChunk; blocks a \
            \ double CC_SweepBegin)."
        (at "active" (UR_FVT|SweepProgress anchor-id))
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
        @doc "Reads enabled-reward-count from FVT row."
        (at "enabled-reward-count" (read FVT|T fvt-id ["enabled-reward-count"]))
    )
    (defun UR_FVT|MemberLinkCount:integer (fvt-id:string)
        @doc "Reads member-link-count from FVT row (ScoreEntityLink admissions)."
        (at "member-link-count" (read FVT|T fvt-id ["member-link-count"]))
    )
    (defun UR_FVT|Mosaic:bool (fvt-id:string)
        @doc "Reads mosaic from FVT row."
        (at "mosaic" (read FVT|T fvt-id ["mosaic"]))
    )
    (defun UR_FVT|MembershipMode:string (fvt-id:string)
        @doc "Reads membership-mode from FVT row."
        (at "membership-mode" (read FVT|T fvt-id ["membership-mode"]))
    )
    (defun UR_FVT|OracleOn:bool (fvt-id:string)
        @doc "DSA: does the node/uptime oracle govern capture on this FVT? false ⇒ capture = units, uptime ≡ 1000, no expiry."
        (at "oracle-on" (read FVT|T fvt-id ["oracle-on"]))
    )
    (defun UR_FVT|SplitMode:string (fvt-id:string)
        @doc "Reads the farm reward-split mode (D1-G2): SPLIT|STAKED (participation, default) | SPLIT|TVL (pool-size). \
            \ Farm (class 0) only consults it at inject; vault/treasury store the default but never read it."
        (at "split-mode" (read FVT|T fvt-id ["split-mode"]))
    )
    (defun UR_FVT|FvtId:string (fvt-id:string)
        @doc "Reads fvt-id field from FVT row."
        (at "fvt-id" (read FVT|T fvt-id ["fvt-id"]))
    )
    ;;
    (defun UR_FVT-SEL|ScoreEntityLink:object{FVT|ScoreEntityLink} (fvt-id:string score-entity-id:string)
        @doc "Reads ScoreEntityLink row; absent rows read as disabled with farm sentinels via default object."
        (with-default-read FVT|T|ScoreEntityLink (UCk_ScoreEntityLink fvt-id score-entity-id)
            (UDC_FVT|ScoreEntityLink CT_SCORE_ENTITY_SCORE false BAR 0.0 0.0 false 0.0 0.0 STREAM_EPOCH fvt-id score-entity-id)
            {"score-entity-type"        := et
            ,"enabled"                  := en
            ,"swpair"                   := sp
            ,"ghost-tvl-weight"         := w
            ,"total-lane-weight"        := tlw
            ,"delegation"               := dg
            ,"capture-units"            := cu
            ,"capture-weight"          := cw
            ,"oracle-ts"                := ots
            ,"fvt-id"                   := fid
            ,"score-entity-id"          := seid}
            (UDC_FVT|ScoreEntityLink et en sp w tlw dg cu cw ots fid seid)
        )
    )
    (defun UR_FVT-SEL|Enabled:bool (fvt-id:string score-entity-id:string)
        @doc "Reads enabled from ScoreEntityLink row."
        (at "enabled" (UR_FVT-SEL|ScoreEntityLink fvt-id score-entity-id))
    )
    (defun UR_FVT-SEL|ScoreEntityType:integer (fvt-id:string score-entity-id:string)
        @doc "Reads score-entity-type from ScoreEntityLink row."
        (at "score-entity-type" (UR_FVT-SEL|ScoreEntityLink fvt-id score-entity-id))
    )
    (defun UR_FVT-SEL|Swpair:string (fvt-id:string score-entity-id:string)
        @doc "Reads swpair from ScoreEntityLink row."
        (at "swpair" (UR_FVT-SEL|ScoreEntityLink fvt-id score-entity-id))
    )
    (defun UR_FVT-SEL|GhostTvlWeight:decimal (fvt-id:string score-entity-id:string)
        @doc "Reads ghost-tvl-weight (W_i) from ScoreEntityLink row."
        (at "ghost-tvl-weight" (UR_FVT-SEL|ScoreEntityLink fvt-id score-entity-id))
    )
    (defun UR_FVT-SEL|TotalLaneWeight:decimal (fvt-id:string score-entity-id:string)
        @doc "Reads total-lane-weight (farm-triplet Level-1 divisor Σ w-user) from ScoreEntityLink row."
        (at "total-lane-weight" (UR_FVT-SEL|ScoreEntityLink fvt-id score-entity-id))
    )
    (defun UR_FVT-SEL|Delegation:bool (fvt-id:string score-entity-id:string)
        @doc "DSA: is this member a delegation agency? false for a normal member."
        (at "delegation" (UR_FVT-SEL|ScoreEntityLink fvt-id score-entity-id))
    )
    (defun UR_FVT-SEL|CaptureUnits:decimal (fvt-id:string score-entity-id:string)
        @doc "DSA: an agency's ideal capacity = min(floor(Q/unit-score), nodes) — the IDEAL inject denominator term. 0.0 for a normal member."
        (at "capture-units" (UR_FVT-SEL|ScoreEntityLink fvt-id score-entity-id))
    )
    (defun UR_FVT-SEL|CaptureWeight:decimal (fvt-id:string score-entity-id:string)
        @doc "DSA: an agency's uptime-adjusted actual = capture-units × uptime/1000 — the inject NUMERATOR (pre-expiry). 0.0 for a normal member."
        (at "capture-weight" (UR_FVT-SEL|ScoreEntityLink fvt-id score-entity-id))
    )
    (defun UR_FVT-SEL|OracleTs:time (fvt-id:string score-entity-id:string)
        @doc "DSA: timestamp of the last oracle write for this agency (now − ts > 25h ⇒ expired ⇒ effective capture 0)."
        (at "oracle-ts" (UR_FVT-SEL|ScoreEntityLink fvt-id score-entity-id))
    )
    (defun UR_FVT-MUW|ContribWeight:decimal (user-id:string fvt-id:string score-entity-id:string)
        @doc "Reads a farm-triplet user's stored Level-1 weight snapshot; 0.0 when absent."
        (with-default-read FVT|T|MemberUserWeight (UCk_MemberUserWeight user-id fvt-id score-entity-id)
            {"contrib-weight"          : 0.0}
            {"contrib-weight"          := cw}
            cw
        )
    )
    (defun UR_FVT-SEL|FvtId:string (fvt-id:string score-entity-id:string)
        @doc "Reads fvt-id from ScoreEntityLink row."
        (at "fvt-id" (UR_FVT-SEL|ScoreEntityLink fvt-id score-entity-id))
    )
    (defun UR_FVT-SEL|ScoreEntityId:string (fvt-id:string score-entity-id:string)
        @doc "Reads score-entity-id from ScoreEntityLink row."
        (at "score-entity-id" (UR_FVT-SEL|ScoreEntityLink fvt-id score-entity-id))
    )
    ;;
    (defun UR_FVT-RG|RpsGlobal:object{FVT|RPS|Global} (fvt-id:string dptf-id:string)
        @doc "Reads global RPS row for one reward token; absent rows read as disabled with zeroed rps fields."
        (with-default-read FVT|T|RPS|Global (UCk_RpsGlobal fvt-id dptf-id)
            (UDC_FVT|RPS|Global false 0.0 0.0 0 0.0 false CT_REWARD_KIND_PLAIN BAR 0 STREAM_EPOCH 0.0 0.0 fvt-id dptf-id)
            {"reward-enabled"       := re
            ,"current-rps"          := cr
            ,"available-rewards"    := ar
            ,"unclaimed-count"      := uc
            ,"zombie-rewards"       := zb
            ,"segmentation"         := seg
            ,"reward-kind"          := rk
            ,"multiplet-family-id"    := tfid
            ,"stream-count"         := sc
            ,"stream-last-release"  := slr
            ,"stream-unreleased"    := sur
            ,"royalty-rewards"      := ry
            ,"fvt-id"               := fid
            ,"dptf-id"              := did}
            (UDC_FVT|RPS|Global re cr ar uc zb seg rk tfid sc slr sur ry fid did)
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
    (defun UR_FVT-RG|ZombieRewards:decimal (fvt-id:string dptf-id:string)
        @doc "Reads zombie-rewards (escrow-on-empty limbo balance) from the global RPS row; 0.0 when absent."
        (at "zombie-rewards" (UR_FVT-RG|RpsGlobal fvt-id dptf-id))
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
    (defun UR_FVT-RG|RewardKind:string (fvt-id:string dptf-id:string)
        @doc "Reads reward-kind from global RPS row."
        (at "reward-kind" (UR_FVT-RG|RpsGlobal fvt-id dptf-id))
    )
    (defun UR_FVT-RG|MultipletFamilyId:string (fvt-id:string dptf-id:string)
        @doc "Reads multiplet-family-id from global RPS row."
        (at "multiplet-family-id" (UR_FVT-RG|RpsGlobal fvt-id dptf-id))
    )
    (defun UR_FVT-RG|StreamCount:integer (fvt-id:string dptf-id:string)
        @doc "Reads stream-count (live linear-release stream positions on this lane; 0 = none) from global RPS row."
        (at "stream-count" (UR_FVT-RG|RpsGlobal fvt-id dptf-id))
    )
    (defun UR_FVT-RG|StreamLastRelease:time (fvt-id:string dptf-id:string)
        @doc "Reads stream-last-release (shared lane drip checkpoint) from global RPS row."
        (at "stream-last-release" (UR_FVT-RG|RpsGlobal fvt-id dptf-id))
    )
    (defun UR_FVT-RG|StreamUnreleased:decimal (fvt-id:string dptf-id:string)
        @doc "Reads stream-unreleased (custodied-but-not-yet-dripped total on this lane) from global RPS row."
        (at "stream-unreleased" (UR_FVT-RG|RpsGlobal fvt-id dptf-id))
    )
    (defun UR_FVT-RG|RoyaltyRewards:decimal (fvt-id:string dptf-id:string)
        @doc "DSA: the royalty pool (uptime-shortfall custody) on this lane; 0.0 when absent / non-delegation."
        (at "royalty-rewards" (UR_FVT-RG|RpsGlobal fvt-id dptf-id))
    )
    (defun UR_FVT-RS|Stream:object{FVT|RPS|Stream} (fvt-id:string dptf-id:string position:integer)
        @doc "Reads one FVT|T|RPS|Stream row (an active stream position). Positions 1..stream-count always exist."
        (read FVT|T|RPS|Stream (UCk_RpsStream fvt-id dptf-id position))
    )
    ;;
    (defun UR_FVT-MF|MultipletFamily:object{FVT|MultipletFamily} (multiplet-family-id:string)
        @doc "Reads full MultipletFamily row."
        (read FVT|T|MultipletFamily multiplet-family-id)
    )
    (defun UR_FVT-MF|Token0Id:string (multiplet-family-id:string)
        @doc "Reads token-0-id from MultipletFamily row."
        (at "token-0-id" (read FVT|T|MultipletFamily multiplet-family-id ["token-0-id"]))
    )
    (defun UR_FVT-MF|Token1Id:string (multiplet-family-id:string)
        @doc "Reads token-1-id from MultipletFamily row."
        (at "token-1-id" (read FVT|T|MultipletFamily multiplet-family-id ["token-1-id"]))
    )
    (defun UR_FVT-MF|Token2Id:string (multiplet-family-id:string)
        @doc "Reads token-2-id from MultipletFamily row."
        (at "token-2-id" (read FVT|T|MultipletFamily multiplet-family-id ["token-2-id"]))
    )
    (defun UR_FVT-MF|Ats01Id:string (multiplet-family-id:string)
        @doc "Reads ats-0-1-id from MultipletFamily row."
        (at "ats-0-1-id" (read FVT|T|MultipletFamily multiplet-family-id ["ats-0-1-id"]))
    )
    (defun UR_FVT-MF|Ats12Id:string (multiplet-family-id:string)
        @doc "Reads ats-1-2-id from MultipletFamily row."
        (at "ats-1-2-id" (read FVT|T|MultipletFamily multiplet-family-id ["ats-1-2-id"]))
    )
    (defun UR_FVT-MF|Rank:integer (multiplet-family-id:string)
        @doc "Reads rank (lane count) from MultipletFamily row."
        (at "rank" (read FVT|T|MultipletFamily multiplet-family-id ["rank"]))
    )
    (defun UR_FVT-MF|Active:bool (multiplet-family-id:string)
        @doc "Reads active from MultipletFamily row."
        (at "active" (read FVT|T|MultipletFamily multiplet-family-id ["active"]))
    )
    (defun UR_FVT-MF|MultipletFamilyId:string (multiplet-family-id:string)
        @doc "Reads multiplet-family-id from MultipletFamily row."
        (at "multiplet-family-id" (read FVT|T|MultipletFamily multiplet-family-id ["multiplet-family-id"]))
    )
    ;;
    (defun UR_FVT-RM|RpsMember:object{FVT|RPS|Member} (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads member-score RPS row; absent rows read as zero g_i / L_i / pending-member-rewards."
        (with-default-read FVT|T|RPS|Member (UCk_RpsMember fvt-id score-entity-id dptf-id)
            (UDC_FVT|RPS|Member 0.0 0.0 0.0 fvt-id score-entity-id dptf-id)
            {"last-farm-rps-g"          := g
            ,"member-deb-rps"          := l
            ,"pending-member-rewards"  := ptr
            ,"fvt-id"                   := fid
            ,"score-entity-id"                 := sid
            ,"dptf-id"                  := did}
            (UDC_FVT|RPS|Member g l ptr fid sid did)
        )
    )
    (defun UR_FVT-RM|LastFarmRpsG:decimal (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads last-farm-rps-g (g_i) from member RPS row."
        (at "last-farm-rps-g" (UR_FVT-RM|RpsMember fvt-id score-entity-id dptf-id))
    )
    (defun UR_FVT-RM|MemberDebRps:decimal (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads member-deb-rps (L_i) from member RPS row."
        (at "member-deb-rps" (UR_FVT-RM|RpsMember fvt-id score-entity-id dptf-id))
    )
    (defun UR_FVT-RM|PendingMemberRewards:decimal (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads pending-member-rewards from member RPS row."
        (at "pending-member-rewards" (UR_FVT-RM|RpsMember fvt-id score-entity-id dptf-id))
    )
    (defun UR_FVT-RM|FvtId:string (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads fvt-id from member RPS row."
        (at "fvt-id" (UR_FVT-RM|RpsMember fvt-id score-entity-id dptf-id))
    )
    (defun UR_FVT-RM|ScoreEntityId:string (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads score-entity-id from member RPS row."
        (at "score-entity-id" (UR_FVT-RM|RpsMember fvt-id score-entity-id dptf-id))
    )
    (defun UR_FVT-RM|DptfId:string (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads dptf-id from member RPS row."
        (at "dptf-id" (UR_FVT-RM|RpsMember fvt-id score-entity-id dptf-id))
    )
    ;;
    (defun UR_FVT-RU|RpsUser:object{FVT|RPS|User}
        (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads user RPS row; absent rows read as zero pending and zero last-rps checkpoint."
        (with-default-read FVT|T|RPS|User (UCk_RpsUser user-id fvt-id score-entity-id dptf-id)
            (UDC_FVT|RPS|User 0.0 0.0 user-id fvt-id score-entity-id dptf-id)
            {"last-rps"         := lr
            ,"pending-rewards"  := pr
            ,"user-id"          := uid
            ,"fvt-id"           := fid
            ,"score-entity-id"         := sid
            ,"dptf-id"          := did}
            (UDC_FVT|RPS|User lr pr uid fid sid did)
        )
    )
    (defun UR_FVT-RU|LastRps:decimal (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads last-rps (user checkpoint vs L_i) from user RPS row."
        (at "last-rps" (UR_FVT-RU|RpsUser user-id fvt-id score-entity-id dptf-id))
    )
    (defun UR_FVT-RU|PendingRewards:decimal (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads pending-rewards from user RPS row."
        (at "pending-rewards" (UR_FVT-RU|RpsUser user-id fvt-id score-entity-id dptf-id))
    )
    (defun UR_FVT-RU|UserId:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads user-id from user RPS row."
        (at "user-id" (UR_FVT-RU|RpsUser user-id fvt-id score-entity-id dptf-id))
    )
    (defun UR_FVT-RU|FvtId:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads fvt-id from user RPS row."
        (at "fvt-id" (UR_FVT-RU|RpsUser user-id fvt-id score-entity-id dptf-id))
    )
    (defun UR_FVT-RU|ScoreEntityId:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads score-entity-id from user RPS row."
        (at "score-entity-id" (UR_FVT-RU|RpsUser user-id fvt-id score-entity-id dptf-id))
    )
    (defun UR_FVT-RU|DptfId:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads dptf-id from user RPS row."
        (at "dptf-id" (UR_FVT-RU|RpsUser user-id fvt-id score-entity-id dptf-id))
    )
    ;;
    ;; --- Cap / stake-flow validation (cheap bools; no keys/select) ---
    ;; URH_FvtScoreEntityLinkKeysForFvt ((keys FVT|T|ScoreEntityLink) scan) RETIRED — M2/#11. Its only caller was
    ;; the vault inject-denominator scan, now replaced by the incrementally-maintained total-deb-score mirror.
    (defun URC_FvtHasScoreEntityLinks:bool (fvt-id:string)
        @doc "True when member-link-count > 0 (cheap row read; preferred over keys/select)."
        (> (UR_FVT|MemberLinkCount fvt-id) 0)
    )
    (defun URC_FvtScoreEntityLinkRowExists:bool (fvt-id:string score-entity-id:string)
        @doc "True when FVT|T|ScoreEntityLink row exists (not default-read absent sentinel)."
        (let
            (
                (trial (try false (read FVT|T|ScoreEntityLink (UCk_ScoreEntityLink fvt-id score-entity-id))))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun URC_FvtRpsGlobalRowExists:bool (fvt-id:string dptf-id:string)
        @doc "True when FVT|T|RPS|Global row exists."
        (let
            (
                (trial (try false (read FVT|T|RPS|Global (UCk_RpsGlobal fvt-id dptf-id))))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    ;; URC_FvtVaultDebDenominator (vault inject divisor via keys-scan) RETIRED — M2/#11. The divisor is now the
    ;; maintained total-deb-score mirror (incrementally kept at stake/toggle/add, point-read at inject). No scan.
    (defun URC_InjectDenominator:decimal (fvt-id:string)
        @doc "Inject RPS divisor: farm S = total-ghost-tvl-weight (LEGACY cache — farms now use \
            \ URC_FarmInjectDenominatorFresh); vault/treasury = the MAINTAINED total-deb-score mirror \
            \ (point-read, incrementally kept — M2/#11). No scan, so it is defcap-safe (UEV_InjectContext)."
        (if (= (UR_FVT|FvtClass fvt-id) 0)
            (UR_FVT|TotalGhostTvlWeight fvt-id)
            (UR_FVT|TotalDebScore fvt-id)
        )
    )
    (defun URC_FarmInjectDenominatorFresh:decimal (fvt-id:string)
        @doc "Split-at-inject farm S computed FRESH (audit LP redesign / Stage 2): sum of each enabled member's \
            \ current staked STOA value (URC_MemberStakedStoaValue). No cache, no sync — the value is base-dependent \
            \ so it must be read at inject. Enumerates members (URD) — inject is an infrequent, bounded operator path. \
            \ DSA: a delegation member contributes its IDEAL capacity (capture-units), NOT its staked value — the \
            \ ideal denominator that lets the uptime shortfall route to royalty (S §4)."
        (let
            (
                (member-ids:[string] (URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
            )
            (fold (+) 0.0
                (map
                    (lambda (score-entity-id:string)
                        (if (UR_FVT-SEL|Delegation fvt-id score-entity-id)
                            (UR_FVT-SEL|CaptureUnits fvt-id score-entity-id)
                            (URC_MemberLevel2Weight
                                fvt-id
                                (UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id)
                                score-entity-id
                                (UR_FVT-SEL|Swpair fvt-id score-entity-id)
                            )
                        )
                    )
                    member-ids
                )
            )
        )
    )
    (defun URC_MaxStreamLanes:integer (account:string)
        @doc "Max concurrent streamed injects the FVT owner konto may run, by Elite tier (snapshot at inject, D5). \
            \ Smart accounts have no Elite level, so they resolve to their sovereign standard account. \
            \ slots = max(1, (major-1)*7 + minor): everyone gets >= 1, capped at STREAM_MAX_LANES (49 at tier 7.7)."
        (let*
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;; 1. smart account → its controlling sovereign (standard) account; standard account → itself
                (tier-acct:string
                    (if (ref-DALOS::UR_AccountType account)
                        (ref-DALOS::UR_AccountSovereign account)
                        account))
                ;; 2. the stored Elite tier of that account, as major.minor integers
                (major:integer (ref-DALOS::UR_Elite-Tier-Major tier-acct))
                (minor:integer (ref-DALOS::UR_Elite-Tier-Minor tier-acct))
                ;; 3. tier → slot count; NOVICE (major 0) underflows to <1 and is floored to the guaranteed 1
                (slots:integer (+ (* (- major 1) 7) minor))
            )
            (if (< slots 1) 1 slots)
        )
    )
    (defun URC_ScoreClassMatchesFvtClass:bool (fvt-class:integer score-class:integer)
        @doc "Admission rule: farm↔LP(0), vault↔TF/SF/NF(1/3/4), treasury↔OF(2)."
        (if (= fvt-class 0)
            (= score-class 0)
            (if (= fvt-class 1)
                (fold (or) false
                    [(= score-class 1) (= score-class 3) (= score-class 4)]
                )
                (if (= fvt-class 2)
                    (= score-class 2)
                    false
                )
            )
        )
    )
    (defun URC_ResolveScoreEntitySwpair:string
        (score-entity-type:integer score-entity-id:string fvt-class:integer)
        @doc "Farm class-0: SWP pair from native LP (score) or silver-score pool (triplet); vault/treasury |."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-SWP:module{SwapperV3} SWP)
                (sentinel:string "|")
                (pool-score-id:string
                    (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                        (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id)
                        score-entity-id
                    )
                )
                (pool-id:string (ref-SCR::UR_SCR|ScoreAqpoolLink pool-score-id))
                (asset-id:string (ref-AQP::UR_AQP|PoolAssetId pool-id))
                (aqp-class:integer (ref-AQP::UR_AQP|PoolAqpClass pool-id))
            )
            (if (= fvt-class 0)
                (if (= aqp-class 0)
                    (ref-SWP::UR_GetLpSwpair asset-id)
                    sentinel
                )
                sentinel
            )
        )
    )
    (defun URC_MemberStakedStoaValue:decimal
        (score-entity-type:integer score-entity-id:string swpair:string)
        @doc "Level-2 farm member weight = the member's STAKED value in wrapped-STOA (audit LP redesign / G2): \
            \ staked LP amount (SCORE total-base) x per-LP STOA value (stoa-value / LP-supply). Uses the \
            \ SWP-maintained stoa-value (cheap point read, refreshed by Talos on every SWP op). 0.0 until users stake. \
            \ Triplet: SUM the three scores' total-base — the hub (boost-link BAR) carries the LP base, the two \
            \ satellites are surplus-only (base 0), so the sum equals the single underlying LP position (mirrors \
            \ URC_ScoreEntityMemberDebWeight's triplet handling; the hub is not necessarily the silver slot)."
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                ;;
                (staked-amount:decimal
                    (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                        (+
                            (ref-SCR::UR_SCR|ScoreTotalBaseScore (ref-SCR::UR_SCR|TripletBronzeScoreId score-entity-id))
                            (+
                                (ref-SCR::UR_SCR|ScoreTotalBaseScore (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                                (ref-SCR::UR_SCR|ScoreTotalBaseScore (ref-SCR::UR_SCR|TripletGoldenScoreId score-entity-id))
                            )
                        )
                        (ref-SCR::UR_SCR|ScoreTotalBaseScore score-entity-id)
                    )
                )
                (lp-supply:decimal (ref-SWP::URC_LpCapacity swpair))
                (per-lp:decimal
                    (if (<= lp-supply 0.0)
                        0.0
                        (/ (ref-SWP::UR_StoaValue swpair) lp-supply)
                    )
                )
            )
            (floor (* staked-amount per-lp) CT_FVT_RPS_PREC)
        )
    )
    (defun UR_ExternalOracle:bool ()
        @doc "The GLOBAL DSA external-oracle switch (single row). ON (default) ⇒ delegation capture is gated by \
            \ oracle freshness; OFF ⇒ oracling is bypassed and the stored capture-weight is trusted."
        (with-default-read FVT|T|DsaOracleConfig FVT|DSA-ORACLE-KEY
            {"external-oracle" : true} {"external-oracle" := x} x)
    )
    (defun UR_OracleValidity:integer ()
        @doc "The GLOBAL DSA oracle-validity window in seconds (default DSA_ORACLE_TTL = 25h). An oracle write older \
            \ than this captures nothing while external-oracle is ON."
        (with-default-read FVT|T|DsaOracleConfig FVT|DSA-ORACLE-KEY
            {"oracle-validity" : DSA_ORACLE_TTL} {"oracle-validity" := v} v)
    )
    (defun URC_MemberEffectiveCapture:decimal (fvt-id:string score-entity-id:string)
        @doc "DSA agency inject NUMERATOR: the member's uptime-adjusted capture-weight, ZEROED when the GLOBAL \
            \ external-oracle switch is ON AND this member's last oracle write has expired (now − oracle-ts > the \
            \ global oracle-validity, default 25h). external-oracle OFF ⇒ capture-weight as-is (oracling bypassed, \
            \ stored weight trusted). No/stale entry while ON ⇒ 0 (a default oracle-ts is always stale). Only \
            \ meaningful for a delegation member (§4)."
        (let
            (
                (cw:decimal (UR_FVT-SEL|CaptureWeight fvt-id score-entity-id))
            )
            (if (and (UR_ExternalOracle)
                     (> (diff-time (at "block-time" (chain-data)) (UR_FVT-SEL|OracleTs fvt-id score-entity-id)) (dec (UR_OracleValidity))))
                0.0
                cw
            )
        )
    )
    ;; NOTE (audit LP redesign): URC_MemberStakedStoaValue above is the correct Level-2 primitive (staked value),
    ;; but it CANNOT be cached via this resolver + the ghost-TVL sync — staked value is base-dependent and the
    ;; sync runs at stake phase 2.1 (before the base updates at phase 4), while the inject defcap checks the
    ;; stale cached S. It must be computed FRESH at inject (split-at-inject, Stage 2). This resolver stays on the
    ;; old whole-pool value until then, so the accumulator/defcap keep working.
    (defun URC_ResolveScoreEntityGhostWeight:decimal
        (score-entity-type:integer score-entity-id:string fvt-class:integer swpair:string)
        @doc "Farm admission: W_i from SWP::UR_StoaValue(swpair); vault/treasury 0.0."
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
            )
            (if (= fvt-class 0)
                (ref-SWP::UR_StoaValue swpair)
                0.0
            )
        )
    )
    (defun URC_MemberLevel2Weight:decimal
        (fvt-id:string score-entity-type:integer score-entity-id:string swpair:string)
        @doc "Mode-aware Level-2 W_i for a NON-delegation farm member (D1-G2 dual reward-split). Reads the farm's \
            \ split-mode and returns: SPLIT|STAKED (participation, default) ⇒ the member's STAKED value \
            \ (URC_MemberStakedStoaValue = staked LP amount × per-LP STOA value); SPLIT|TVL (pool-size) ⇒ the whole \
            \ swpair TVL (URC_ResolveScoreEntityGhostWeight at farm class 0 = SWP::UR_StoaValue). Used IDENTICALLY by \
            \ the fresh inject denominator S (URC_FarmInjectDenominatorFresh) and the per-member numerator \
            \ (XI_1|FarmSplitInject / URC_ProjectedIndexAdvance) so member slices always sum to the injected amount. \
            \ A mode switch re-weights only future injects (RPS is checkpoint-based). Delegation members bypass this \
            \ (they weight by capture, not staked value/TVL)."
        (if (= (UR_FVT|SplitMode fvt-id) CT_SPLIT_MODE_TVL)
            (URC_ResolveScoreEntityGhostWeight score-entity-type score-entity-id 0 swpair)
            (URC_MemberStakedStoaValue score-entity-type score-entity-id swpair)
        )
    )
    (defun URC_ScoreEntityMemberDebWeight:decimal
        (score-entity-type:integer score-entity-id:string)
        @doc "Vault/treasury Tier-2 member weight: score total-deb or sum of triplet score totals."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                (let
                    (
                        (bronze-id:string (ref-SCR::UR_SCR|TripletBronzeScoreId score-entity-id))
                        (silver-id:string (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                        (golden-id:string (ref-SCR::UR_SCR|TripletGoldenScoreId score-entity-id))
                    )
                    (+
                        (ref-SCR::UR_SCR|ScoreTotalDebScore bronze-id)
                        (+
                            (ref-SCR::UR_SCR|ScoreTotalDebScore silver-id)
                            (ref-SCR::UR_SCR|ScoreTotalDebScore golden-id)
                        )
                    )
                )
                (ref-SCR::UR_SCR|ScoreTotalDebScore score-entity-id)
            )
        )
    )
    (defun URC_ScoreEntityMemberWeight:decimal
        (fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "Tier-2 member tranche weight: farm ghost W_i; vault/treasury aggregate deb."
        (if (= (UR_FVT|FvtClass fvt-id) 0)
            (UR_FVT-SEL|GhostTvlWeight fvt-id score-entity-id)
            (URC_ScoreEntityMemberDebWeight score-entity-type score-entity-id)
        )
    )
    (defun URC_ScoreEntityMemberTier2Divisor:decimal
        (fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "Tier-2 L_i advance divisor. Branches on the TRUE-TRIPLET flag (any FVT class), not class: \
            \ true triplet → maintained Σ w-user (total-lane-weight point-read, snapshot-maintained at stake, \
            \ no staker scan); non-true triplet → Σ of the 3 bundled scores' total-deb; singular score → its total-deb."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                (if (ref-SCR::UR_SCR|TripletTrueTriplet score-entity-id)
                    (UR_FVT-SEL|TotalLaneWeight fvt-id score-entity-id)
                    (URC_ScoreEntityMemberDebWeight score-entity-type score-entity-id)
                )
                (URC_ScoreEntityMemberDebWeight score-entity-type score-entity-id)
            )
        )
    )
    (defun URC_ComputeTripletLanes:object
        (user-id:string pool-id:string triplet-id:string)
        @doc "Lane weights from silver base-score × ANK promiles on bronze/silver/golden boost-class-links."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (silver-id:string (ref-SCR::UR_SCR|TripletSilverScoreId triplet-id))
                (bronze-id:string (ref-SCR::UR_SCR|TripletBronzeScoreId triplet-id))
                (golden-id:string (ref-SCR::UR_SCR|TripletGoldenScoreId triplet-id))
                (base:decimal (ref-SCR::UR_U-SCR|UserScoreBaseScore user-id pool-id silver-id))
                ;; Lane flooring precision is class-agnostic: LP scores use the pool leg's decimals; non-LP
                ;; (vault/treasury true triplets, lp-denominator BAR) use the score's own precision.
                (lp-denom:string (ref-SCR::UR_SCR|ScoreLpDenominator silver-id))
                (p:integer
                    (if (= lp-denom BAR)
                        (ref-SCR::UR_SCR|ScorePrecision silver-id)
                        (ref-DPTF::UR_Decimals lp-denom)))
                (prom-b:decimal (ref-ANK::UR_UB|AggregatePromile user-id (ref-SCR::UR_SCR|ScoreBoostClassLink bronze-id)))
                (prom-s:decimal (ref-ANK::UR_UB|AggregatePromile user-id (ref-SCR::UR_SCR|ScoreBoostClassLink silver-id)))
                (prom-g:decimal (ref-ANK::UR_UB|AggregatePromile user-id (ref-SCR::UR_SCR|ScoreBoostClassLink golden-id)))
                (lane-b:decimal (floor (* base (/ prom-b 1000.0)) p))
                (lane-s:decimal (floor (* base (/ prom-s 1000.0)) p))
                (lane-g:decimal (floor (* base (/ prom-g 1000.0)) p))
            )
            {"lane-b" : lane-b, "lane-s" : lane-s, "lane-g" : lane-g
            ,"w-user" : (+ lane-b (+ lane-s lane-g))}
        )
    )
    (defun URC_TripletUserLaneWeightLive:decimal
        (user-id:string pool-id:string triplet-id:string)
        @doc "Live w-user for a TRUE triplet (Σ lanes = silver base × Σ promiles). Used ONLY to (re)snapshot the \
            \ stored contrib-weight at stake/unstake (phase 4.6); banking reads the snapshot, not this."
        (at "w-user" (URC_ComputeTripletLanes user-id pool-id triplet-id))
    )
    (defun URC_TripletUserDebSum:decimal
        (user-id:string triplet-id:string)
        @doc "Non-true triplet user weight: Σ of the user's deb-score across the 3 bundled scores, each read at \
            \ its own aqpool-link. Matches the non-true divisor (Σ of the 3 scores' total-deb) → conservation."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (bronze-id:string (ref-SCR::UR_SCR|TripletBronzeScoreId triplet-id))
                (silver-id:string (ref-SCR::UR_SCR|TripletSilverScoreId triplet-id))
                (golden-id:string (ref-SCR::UR_SCR|TripletGoldenScoreId triplet-id))
            )
            (+
                (ref-SCR::UR_U-SCR|UserScoreDebScore user-id (ref-SCR::UR_SCR|ScoreAqpoolLink bronze-id) bronze-id)
                (+
                    (ref-SCR::UR_U-SCR|UserScoreDebScore user-id (ref-SCR::UR_SCR|ScoreAqpoolLink silver-id) silver-id)
                    (ref-SCR::UR_U-SCR|UserScoreDebScore user-id (ref-SCR::UR_SCR|ScoreAqpoolLink golden-id) golden-id)
                )
            )
        )
    )
    (defun URC_ScoreEntityUserWeight:decimal
        (user-id:string fvt-id:string pool-id:string score-entity-type:integer score-entity-id:string)
        @doc "Tier-1 user weight (numerator). Branches on the TRUE-TRIPLET flag (any FVT class): true triplet → \
            \ stored contrib-weight snapshot (shares the total-lane-weight divisor basis → conservation); \
            \ non-true triplet → Σ user deb over the 3 bundled scores; singular score → SCR deb-user."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                (if (ref-SCR::UR_SCR|TripletTrueTriplet score-entity-id)
                    (UR_FVT-MUW|ContribWeight user-id fvt-id score-entity-id)
                    (URC_TripletUserDebSum user-id score-entity-id)
                )
                (ref-SCR::UR_U-SCR|UserScoreDebScore user-id pool-id score-entity-id)
            )
        )
    )
    (defun URC_FvtUserStillPresent:bool (fvt-id:string user-id:string)
        @doc "HEAVY (enumerates the FVT's enabled score-entities — one `select` over ScoreEntityLink): true iff the \
            \ user still holds a nonzero Tier-1 weight in AT LEAST ONE of them. Used by the unstake-side presence \
            \ recompute to decide whether to flip is-present → false. Must run AFTER phase 4 SCORE mutation + phase \
            \ 4.6 lane re-snapshot so the weights reflect the post-unstake state. pool-id is only consulted for \
            \ singular members (BAR for triplets, whose branch ignores it)."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            (fold (or) false
                (map
                    (lambda (se-id:string)
                        (let
                            (
                                (se-type:integer (UR_FVT-SEL|ScoreEntityType fvt-id se-id))
                            )
                            (> (URC_ScoreEntityUserWeight user-id fvt-id
                                   (if (= se-type CT_SCORE_ENTITY_TRIPLET) BAR (ref-SCR::UR_SCR|ScoreAqpoolLink se-id))
                                   se-type se-id)
                               0.0)
                        )
                    )
                    (URH_FvtEnabledScoreEntityIdsForFvt fvt-id)
                )
            )
        )
    )
    (defun URC_ResolveEmployedScoreEntity:object
        (score-id:string)
        @doc "Map employed SCR score-id to score-entity-type + score-entity-id for RPS banking."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            (if (ref-SCR::UR_SCR|ScoreTriplet score-id)
                {"score-entity-type" : CT_SCORE_ENTITY_TRIPLET
                ,"score-entity-id"   : (ref-SCR::UR_SCR|ScoreTripletId score-id)}
                {"score-entity-type" : CT_SCORE_ENTITY_SCORE
                ,"score-entity-id"   : score-id}
            )
        )
    )
    (defun URC_ResolvePoolScoreId:string (score-entity-type:integer score-entity-id:string)
        @doc "Pool id for collect/settle SCR reads: score pool or triplet silver pool."
        (let 
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            (if (= score-entity-type CT_SCORE_ENTITY_SCORE)
                (ref-SCR::UR_SCR|ScoreAqpoolLink score-entity-id)
                (ref-SCR::UR_SCR|ScoreAqpoolLink
                    (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id)
                )
            )
        )
    )
    (defun URC_MultipletFamilyExists:bool (multiplet-family-id:string)
        @doc "True when FVT|T|MultipletFamily row exists."
        (let
            (
                (trial (try false (read FVT|T|MultipletFamily multiplet-family-id)))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun URC_FvtHasAnyMemberLink:bool (fvt-id:string)
        @doc "True when FVT has at least one ScoreEntityLink row (blocks C_SetMosaic). \
            \ Uses URD keys filter — not select (select/keys disallowed inside defcaps)."
        (URC_FvtHasScoreEntityLinks fvt-id)
    )
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
        @doc "True when employed score maps to enabled ScoreEntityLink on issued FVT with ≥1 reward DPTF."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (entity:object (URC_ResolveEmployedScoreEntity score-id))
                (fvt-id:string (ref-SCR::UR_SCR|ScoreFvtLink score-id))
                (score-entity-id:string (at "score-entity-id" entity))
            )
            (fold (and) true
                [
                    (!= fvt-id BAR)
                    (URC_FvtExists fvt-id)
                    (UR_FVT-SEL|Enabled fvt-id score-entity-id)
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
        @doc "Employed scores that run phase 2.1 settle — fvt-link≠BAR and parent ScoreEntityLink enabled."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            (filter
                (lambda (score-id:string)
                    (let
                        (
                            (fvt-link:string (ref-SCR::UR_SCR|ScoreFvtLink score-id))
                            (entity:object (URC_ResolveEmployedScoreEntity score-id))
                            (score-entity-id:string (at "score-entity-id" entity))
                        )
                        (fold (and) true
                            [
                                (!= score-entity-id BAR)
                                (!= fvt-link BAR)
                                (UR_FVT-SEL|Enabled fvt-link score-entity-id)
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
        @doc "Internal: cheap bundle lookup (filter ≤7 rows) on URH_FVT|SettleFvtRewardBundle — avoids repeat select when scores share FVT."
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
        (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Internal: true when FVT|T|RPS|User row exists (UrStoa UR_URV|IzAccount try-read pattern)."
        (let
            (
                (trial (try false (read FVT|T|RPS|User (UCk_RpsUser user-id fvt-id score-entity-id dptf-id))))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun URC_FvtRpsMemberRowExists:bool
        (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Internal: true when FVT|T|RPS|Member row exists."
        (let
            (
                (trial (try false (read FVT|T|RPS|Member (UCk_RpsMember fvt-id score-entity-id dptf-id))))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun URC_FvtTier1IndexRps:decimal
        (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Internal: Tier-1 accrual index vs user last-rps. Farm (class 0): L_i on RPS|Member. \
            \ Vault/treasury (class 1/2): UrStoa single-tier — global G on RPS|Global (README vault simplification)."
        (if (= (UR_FVT|FvtClass fvt-id) 0)
            (UR_FVT-RM|MemberDebRps fvt-id score-entity-id dptf-id)
            (UR_FVT-RG|CurrentRps fvt-id dptf-id)
        )
    )
    (defun URC_UserTier1AvailableRewards:decimal
        (user-id:string fvt-id:string score-entity-id:string dptf-id:string deb-user:decimal)
        @doc "Internal: UrStoa URC_AvailableRewards — pending + floor(deb×(index−last_rps), reward DPTF decimals). \
            \ index = L_i (farm) or G (vault/treasury). deb-user is pre-2.3 OLD SCR deb-score."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (current-pending:decimal (UR_FVT-RU|PendingRewards user-id fvt-id score-entity-id dptf-id))
                (last-rps:decimal (UR_FVT-RU|LastRps user-id fvt-id score-entity-id dptf-id))
                (index-rps:decimal (URC_FvtTier1IndexRps fvt-id score-entity-id dptf-id))
                (reward-prec:integer (ref-DPTF::UR_Decimals dptf-id))
                (diff-rps:decimal (- index-rps last-rps))
                (gained:decimal (floor (* deb-user diff-rps) reward-prec))
            )
            (+ current-pending gained)
        )
    )
    (defun URC_CollectClaimableRewards:decimal
        (patron:string pool-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "UrStoa claimable with the two-tier last-claimant sweep (M1/#10): if this is the last user globally \
            \ (global unclaimed-count 1) → pay the whole global available-rewards (sweeps the remainder); else, \
            \ FARMS ONLY (class 0, two-tier L_i), if last user in this member (member unclaimed-count 1) → pay the \
            \ member's available-rewards (sweeps the tier-1 floor dust); else the normal floored pending + \
            \ weight×(index−last_rps). The member branch is FARM-ONLY: vault/treasury (class≠0) are single-tier \
            \ (global G), their member mini-vault is never funded (inject bumps only the global pool), so their \
            \ dust is swept by the gc==1 global branch — taking the member branch there would pay 0 (audit R2 \
            \ regression fix: treasury single-staker-per-member had gc>1 ∧ mc==1 → paid the empty member vault). \
            \ Amounts in token-0 (ATS base); the ladder converts downstream and is itself dust-free."
        (let
            (
                (mc:integer (UR_FVT-MV|UnclaimedCount fvt-id score-entity-id reward-dptf-id))
                (gc:integer (UR_FVT-RG|UnclaimedCount fvt-id reward-dptf-id))
                (deb-user:decimal (URC_ScoreEntityUserWeight patron fvt-id pool-id score-entity-type score-entity-id))
            )
            (if (= gc 1)
                (UR_FVT-RG|AvailableRewards fvt-id reward-dptf-id)
                (if (and (= (UR_FVT|FvtClass fvt-id) 0) (= mc 1))
                    (UR_FVT-MV|AvailableRewards fvt-id score-entity-id reward-dptf-id)
                    (URC_UserTier1AvailableRewards patron fvt-id score-entity-id reward-dptf-id deb-user)
                )
            )
        )
    )
    (defun URC_ReleasableToNow:decimal (fvt-id:string dptf-id:string)
        @doc "Read-only: the total a drip would release RIGHT NOW across the lane's active streams — rate*elapsed \
            \ floored to the token's decimals, or the exact remainder for a finished stream. Mirrors XI_ReleaseStream's \
            \ per-stream rel WITHOUT writes (for URC_LiveClaimable / URC_StreamStatus). 0.0 when no stream is active."
        (let ((count:integer (UR_FVT-RG|StreamCount fvt-id dptf-id)))
            (if (= count 0)
                0.0
                (let*
                    (
                        (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                        (now:time (at "block-time" (chain-data)))
                        (last:time (UR_FVT-RG|StreamLastRelease fvt-id dptf-id))
                        (reward-dec:integer (ref-DPTF::UR_Decimals dptf-id))
                    )
                    (fold
                        (lambda (acc:decimal idx:integer)
                            (let*
                                (
                                    (s:object{FVT|RPS|Stream} (UR_FVT-RS|Stream fvt-id dptf-id idx))
                                    (remaining:decimal (- (at "amount" s) (at "released" s)))
                                    (rel:decimal
                                        (if (>= now (at "finish" s))
                                            remaining
                                            (let ((by-rate:decimal (floor (* (at "rate" s) (diff-time now last)) reward-dec)))
                                                (if (> by-rate remaining) remaining by-rate))))
                                )
                                (+ acc rel)))
                        0.0
                        (enumerate 1 count))))))
    (defun URC_ProjectedIndexAdvance:decimal
        (fvt-id:string score-entity-type:integer score-entity-id:string dptf-id:string releasable:decimal)
        @doc "Read-only: the Tier-1 index (L_i / G) advance that distributing `releasable` right now would produce \
            \ (for URC_LiveClaimable). VAULT/TREASURY: floor(releasable / total-deb-score, 48). FARM: member-slice = \
            \ floor(releasable × member-STOA-weight / S, reward-dec), then floor(member-slice / member-deb-divisor, 48) \
            \ — mirrors XI_1|FarmSplitInject (ignores the rare pending-member ptr flush). Uses UC_ComputeInjectGainedRps."
        (if (= (UR_FVT|FvtClass fvt-id) 0)
            (let*
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (reward-dec:integer (ref-DPTF::UR_Decimals dptf-id))
                    (s-farm:decimal (URC_FarmInjectDenominatorFresh fvt-id))
                    (w-i:decimal (URC_MemberLevel2Weight fvt-id score-entity-type score-entity-id (UR_FVT-SEL|Swpair fvt-id score-entity-id)))
                    (member-slice:decimal (if (> s-farm 0.0) (floor (/ (* releasable w-i) s-farm) reward-dec) 0.0))
                    (total-deb:decimal (URC_ScoreEntityMemberTier2Divisor fvt-id score-entity-type score-entity-id))
                )
                (if (> total-deb 0.0) (floor (/ member-slice total-deb) CT_FVT_RPS_PREC) 0.0))
            (UC_ComputeInjectGainedRps releasable (URC_InjectDenominator fvt-id))))
    (defun URC_LiveClaimable:decimal
        (user-id:string fvt-id:string pool-id:string score-entity-type:integer score-entity-id:string dptf-id:string)
        @doc "Read-only PROJECTION of the user's claimable INCLUDING stream time vested up to now (drips the lane in \
            \ memory, no writes): pending + floor(deb-user × (projected-index − last-rps), reward-dec), where \
            \ projected-index = current index + URC_ProjectedIndexAdvance(releasable-to-now). Lets the UI show accrual \
            \ ticking with no tx. Uses the NORMAL per-user path — for the last-claimant dust-sweep edge the real \
            \ collect pays the whole available-rewards, so this slightly under-estimates there (a UI hint, not a promise)."
        (let*
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (reward-dec:integer (ref-DPTF::UR_Decimals dptf-id))
                (deb-user:decimal (URC_ScoreEntityUserWeight user-id fvt-id pool-id score-entity-type score-entity-id))
                (releasable:decimal (URC_ReleasableToNow fvt-id dptf-id))
                (proj-index:decimal
                    (+ (URC_FvtTier1IndexRps fvt-id score-entity-id dptf-id)
                       (URC_ProjectedIndexAdvance fvt-id score-entity-type score-entity-id dptf-id releasable)))
                (pending:decimal (UR_FVT-RU|PendingRewards user-id fvt-id score-entity-id dptf-id))
                (last-rps:decimal (UR_FVT-RU|LastRps user-id fvt-id score-entity-id dptf-id))
            )
            (+ pending (floor (* deb-user (- proj-index last-rps)) reward-dec))))
    (defun URC_StreamStatus:object (fvt-id:string dptf-id:string)
        @doc "Read-only lane stream summary for the UI (the 7x7 view): active-count (live positions 1..stream-count), \
            \ total-rate (Σ rate over streams NOT yet finished), earliest-finish (soonest a stream ends; STREAM_EPOCH \
            \ when none), unreleased (custodied-but-not-yet-dripped). Reads positions 1..stream-count."
        (let ((count:integer (UR_FVT-RG|StreamCount fvt-id dptf-id)))
            (if (= count 0)
                { "active-count" : 0, "total-rate" : 0.0, "earliest-finish" : STREAM_EPOCH, "unreleased" : 0.0 }
                (let
                    (
                        (now:time (at "block-time" (chain-data)))
                        (agg:object
                            (fold
                                (lambda (acc:object idx:integer)
                                    (let ((s:object{FVT|RPS|Stream} (UR_FVT-RS|Stream fvt-id dptf-id idx)))
                                        { "rate" : (+ (at "rate" acc) (if (> (at "finish" s) now) (at "rate" s) 0.0))
                                        , "earliest" : (if (< (at "finish" s) (at "earliest" acc)) (at "finish" s) (at "earliest" acc)) }))
                                { "rate" : 0.0, "earliest" : (at "finish" (UR_FVT-RS|Stream fvt-id dptf-id 1)) }
                                (enumerate 1 count)))
                    )
                    { "active-count" : count
                    , "total-rate" : (at "rate" agg)
                    , "earliest-finish" : (at "earliest" agg)
                    , "unreleased" : (UR_FVT-RG|StreamUnreleased fvt-id dptf-id) }))))
    (defun URC_SettleScorePlanRows:[object{FVT|SettleScorePlan}]
        (settle-scores:[string] fvt-reward-bundle:[object{FVT|SettleFvtRewards}])
        @doc "Distinct score-entity settle plans — triplet members collapse to one triplet-id plan."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (entity-ids:[string]
                    (distinct
                        (map
                            (lambda (score-id:string)
                                (at "score-entity-id" (URC_ResolveEmployedScoreEntity score-id))
                            )
                            settle-scores
                        )
                    )
                )
            )
            (map
                (lambda (score-entity-id:string)
                    (let
                        (
                            (probe-score:string
                                (if (= (take 2 score-entity-id) "T|")
                                    (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id)
                                    score-entity-id
                                )
                            )
                            (fvt-id:string (ref-SCR::UR_SCR|ScoreFvtLink probe-score))
                        )
                        (UDC_FVT|SettleScorePlan
                            (UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id)
                            score-entity-id
                            fvt-id
                            (URC_FvtRewardDptfIdsFromBundle fvt-id fvt-reward-bundle)
                        )
                    )
                )
                entity-ids
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
    (defun URC_SettlePlanEmployedScoreIds:[string] (plan:object{FVT|SettleScorePlan})
        @doc "Employed SCR score-ids for nz/unclaimed probes — triplet plans expand to bronze/silver/golden."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (entity-type:integer (at "score-entity-type" plan))
                (entity-id:string (at "score-entity-id" plan))
            )
            (if (= entity-type CT_SCORE_ENTITY_TRIPLET)
                [
                    (ref-SCR::UR_SCR|TripletBronzeScoreId entity-id)
                    (ref-SCR::UR_SCR|TripletSilverScoreId entity-id)
                    (ref-SCR::UR_SCR|TripletGoldenScoreId entity-id)
                ]
                [entity-id]
            )
        )
    )
    (defun URC_BuildPreScoreNzFlags:[object{FVT|ScorePreNzFlag}]
        (beneficiary-id:string pool-id:string settle-scores:[string])
        @doc "Pre-SCORE nz snapshot per employed score-id."
        (map
            (lambda (score-id:string)
                (UDC_FVT|ScorePreNzFlag score-id (URC_UserScoreTripleIsNonZero beneficiary-id pool-id score-id))
            )
            settle-scores
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
                    (> (UR_FVT-RU|PendingRewards beneficiary-id fvt-id (at "score-entity-id" plan) reward-dptf-id) 0.0)
                )
                plans
            )
        )
    )
    (defun URC_SettleStakePendingIgnis:decimal (settle-scores:[string] distinct-fvts:[string])
        @doc "Internal: phase 2.1 settle IGNIS from precomputed lists (C_*StakeFlow / URHC_BuildStakeSettleBundle). \
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
    ;; --- Shared deb-staleness SCAN predicates (M3 #12 — scan + fix use the SAME predicate, cannot diverge) ---
    (defun URC_FvtMemberDebNeedsFix:bool
        (fvt-id:string user-id:string score-entity-type:integer score-entity-id:string)
        @doc "True iff (user, member) is deb-based (singular / NON-true triplet) AND deb-stale — the exact condition \
            \ XI_FixUserMemberDeb acts on. Shared by the sweep scan so scan and fix never disagree. True triplets \
            \ (deb-independent lanes) → always false."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (triplet:bool (= score-entity-type CT_SCORE_ENTITY_TRIPLET))
                (deb-based:bool (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET) (not (ref-SCR::UR_SCR|TripletTrueTriplet score-entity-id)) true))
            )
            (and deb-based
                (if triplet
                    (fold (or) false
                        [ (ref-SCR::URC_U-SCR|UserScoreDebStale user-id (ref-SCR::UR_SCR|ScoreAqpoolLink (ref-SCR::UR_SCR|TripletBronzeScoreId score-entity-id)) (ref-SCR::UR_SCR|TripletBronzeScoreId score-entity-id))
                          (ref-SCR::URC_U-SCR|UserScoreDebStale user-id (ref-SCR::UR_SCR|ScoreAqpoolLink (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id)) (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                          (ref-SCR::URC_U-SCR|UserScoreDebStale user-id (ref-SCR::UR_SCR|ScoreAqpoolLink (ref-SCR::UR_SCR|TripletGoldenScoreId score-entity-id)) (ref-SCR::UR_SCR|TripletGoldenScoreId score-entity-id)) ])
                    (ref-SCR::URC_U-SCR|UserScoreDebStale user-id (ref-SCR::UR_SCR|ScoreAqpoolLink score-entity-id) score-entity-id)))
        )
    )
    (defun URC_FvtUserHasStaleMemberIn:bool (fvt-id:string user-id:string members:[string])
        @doc "True iff the user has ≥1 deb-stale member among the PRE-COMPUTED `members` (the FVT's enabled \
            \ score-entity-ids — user-INVARIANT). Lets a bulk scan compute the member list ONCE and reuse it for \
            \ every present user, instead of re-scanning FVT|T|ScoreEntityLink per user (the accidental \
            \ O(users × member-table) blow-up). Per-member work is point reads only."
        (fold (or) false
            (map
                (lambda (m:string) (URC_FvtMemberDebNeedsFix fvt-id user-id (UR_FVT-SEL|ScoreEntityType fvt-id m) m))
                members))
    )
    (defun URC_FvtUserHasStaleMember:bool (fvt-id:string user-id:string)
        @doc "True iff the user has ≥1 deb-stale member in the FVT. Single-user convenience (does one member \
            \ scan); BULK callers must use URC_FvtUserHasStaleMemberIn with a hoisted member list."
        (URC_FvtUserHasStaleMemberIn fvt-id user-id (URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
    )
    (defun URC_FvtUserStaleMemberCountIn:integer (fvt-id:string user-id:string members:[string])
        @doc "Count of the user's deb-stale members among the PRE-COMPUTED `members` — the 2e forced-fix \
            \ increment. Hoisted-member twin of URC_FvtUserStaleMemberCount (no per-user member re-scan)."
        (fold (+) 0
            (map
                (lambda (m:string) (if (URC_FvtMemberDebNeedsFix fvt-id user-id (UR_FVT-SEL|ScoreEntityType fvt-id m) m) 1 0))
                members))
    )
    (defun URC_FvtUserStaleMemberCount:integer (fvt-id:string user-id:string)
        @doc "Count of the user's deb-stale members in the FVT (the 2e forced-fix increment). Single-user \
            \ convenience (one member scan); bulk callers use URC_FvtUserStaleMemberCountIn."
        (URC_FvtUserStaleMemberCountIn fvt-id user-id (URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
    )
    (defun URC_FvtSweepTotalPresent:integer (score-ids:[string])
        @doc "Total present holders across every FVT member employing the swept boost-class = the paginated \
            \ recompute-set size for CC_SweepBegin. Read-only; sweep-in-progress keeps URH_FvtPresentUsers fixed \
            \ across the CC-batch's txs. FVT-local twin of MTX-AQP::URC_SweepTotalPresent (the defpact's copy) — \
            \ both fold the SAME URH_FvtPresentUsers, so they agree by construction."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            (fold (+) 0
                (map
                    (lambda (sid:string) (length (URH_FvtPresentUsers (ref-SCR::UR_SCR|ScoreFvtLink sid))))
                    score-ids))
        )
    )
    ;; FVT|T|AgencyFee  Key = <FVT-ID> | <Score-Entity-ID>  (DSA operator-fee mirror; Phase 5b)
    (defun UR_FVT-AF|FeePerMille:integer (fvt-id:string score-entity-id:string)
        @doc "A delegation member's operator fee-per-mille (0 when unset ⇒ no split)."
        (with-default-read FVT|T|AgencyFee (UCk_ScoreEntityLink fvt-id score-entity-id)
            {"fee-per-mille" : 0} {"fee-per-mille" := f} f)
    )
    (defun UR_FVT-AF|Operator:string (fvt-id:string score-entity-id:string)
        @doc "A delegation member's operator konto (BAR when unset)."
        (with-default-read FVT|T|AgencyFee (UCk_ScoreEntityLink fvt-id score-entity-id)
            {"operator-konto" : BAR} {"operator-konto" := o} o)
    )
    ;; FVT|T|QualitySplit  Key = <FVT-ID> | <DPTF-ID>  (DSA Round B heterogeneous split matrix)
    (defun UR_FVT-QS|Mode:string (fvt-id:string dptf-id:string)
        @doc "A MULTIPLET_BASE reward's quality-split mode (HOMOGENEOUS when unset ⇒ unchanged lane→one-token routing)."
        (with-default-read FVT|T|QualitySplit (UCk_RpsGlobal fvt-id dptf-id)
            {"mode" : CT_REWARD_MODE_HOMOGENEOUS} {"mode" := m} m)
    )
    (defun UR_FVT-QS|BronzeSplit:[integer] (fvt-id:string dptf-id:string)
        @doc "Heterogeneous bronze-lane split [to-t0 to-t1 to-t2] per-mille."
        (at "bronze-split" (read FVT|T|QualitySplit (UCk_RpsGlobal fvt-id dptf-id) ["bronze-split"]))
    )
    (defun UR_FVT-QS|SilverSplit:[integer] (fvt-id:string dptf-id:string)
        @doc "Heterogeneous silver-lane split [to-t0 to-t1 to-t2] per-mille."
        (at "silver-split" (read FVT|T|QualitySplit (UCk_RpsGlobal fvt-id dptf-id) ["silver-split"]))
    )
    (defun UR_FVT-QS|GoldSplit:[integer] (fvt-id:string dptf-id:string)
        @doc "Heterogeneous gold-lane split [to-t0 to-t1 to-t2] per-mille."
        (at "gold-split" (read FVT|T|QualitySplit (UCk_RpsGlobal fvt-id dptf-id) ["gold-split"]))
    )
    ;; [URH] heavy-read
    (defun URH_FvtPresentUsers:[string] (fvt-id:string)
        @doc "HEAVY (one `select` over the small purpose-built presence table): all ouronet-ids currently marked \
            \ present in this FVT. Used by the fresh/checked inject + anchor sweeps to enumerate an FVT's users \
            \ without scanning RPS|User. Stale `true` rows are harmless (consumer no-ops on zero-weight)."
        (map (at "ouronet-id")
            (select FVT|T|UserPresence ["ouronet-id"]
                (and? (where "fvt-id" (= fvt-id)) (where "is-present" (= true)))
            )
        )
    )
    ;;
    ;; --- FVT|T|RPS|Global selects (stake hot path: one batched select via URH_FVT|SettleFvtRewardBundle) ---
    (defun URH_FVT-RG|EnabledRewardRows:[string] (fvt-id:string)
        @doc "Expensive read: enabled reward dptf-ids for one fvt-id (FVT|T|RPS|Global.reward-enabled true). \
            \ Prefer URH_FVT|SettleFvtRewardBundle when resolving multiple distinct FVTs in one tx."
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
    (defun URH_FVT|SettleFvtRewardBundle:[object{FVT|SettleFvtRewards}] (distinct-fvts:[string])
        @doc "Expensive read: ONE select on FVT|T|RPS|Global for all distinct-fvts, then group to SettleFvtRewards rows. \
            \ Not N× URH_FVT-RG|EnabledRewardRows — single table pass per C_*StakeFlow."
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
    (defun URH_FvtEnabledScoreEntityIdsForFvt:[string] (fvt-id:string)
        @doc "Expensive read: enabled score-entity-ids for one FVT — inject/collect ghost-TV lazy sync scope."
        (map
            (lambda (row:object)
                (at "score-entity-id" row)
            )
            (select FVT|T|ScoreEntityLink ["score-entity-id"]
                (and?
                    (where "fvt-id" (= fvt-id))
                    (where "enabled" (= true))
                )
            )
        )
    )
    (defun URHC_BuildInjectScorePlans:[object{FVT|SettleScorePlan}] (fvt-id:string)
        @doc "Enabled ScoreEntityLinks on FVT × enabled reward dptf-ids — ghost TVL lazy-sync scope."
        (let
            (
                (reward-dptf-ids:[string] (URH_FVT-RG|EnabledRewardRows fvt-id))
                (score-entity-ids:[string] (URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
            )
            (map
                (lambda (score-entity-id:string)
                    (UDC_FVT|SettleScorePlan
                        (UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id)
                        score-entity-id
                        fvt-id
                        reward-dptf-ids
                    )
                )
                score-entity-ids
            )
        )
    )
    (defun URHC_BuildStakeSettleBundle:object
        (pool-id:string beneficiary-id:string)
        @doc "Internal: one URH_FVT|SettleFvtRewardBundle per C_*StakeFlow pass — reuse in phases 2.1, 2.35, and 2.4. \
            \ pre-nz-flags snapshot beneficiary nz state before SCORE."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                ;;
                (employed-ids:[string] (ref-AQP::URC_PoolActiveScoreIds pool-id))
                (settle-scores:[string] (URC_SettleEligibleEmployedScores employed-ids))
                (distinct-fvts:[string] (URC_SettleDistinctFvtLinks settle-scores))
                (fvt-reward-bundle:[object{FVT|SettleFvtRewards}] (URH_FVT|SettleFvtRewardBundle distinct-fvts))
                (settle-plans:[object{FVT|SettleScorePlan}] (URC_SettleScorePlanRows settle-scores fvt-reward-bundle))
                (pre-nz-flags:[object{FVT|ScorePreNzFlag}]
                    (URC_BuildPreScoreNzFlags beneficiary-id pool-id settle-scores)
                )
                ;; M2/#11: pre-SCORE live deb-weight per settled member, so phase 4.6 can delta the vault
                ;; total-deb mirror over only the touched members (no scan).
                (pre-member-debs:[object{FVT|MemberPreDeb}]
                    (map
                        (lambda (plan:object{FVT|SettleScorePlan})
                            {"fvt-id"            : (at "fvt-id" plan)
                            ,"score-entity-type" : (at "score-entity-type" plan)
                            ,"score-entity-id"   : (at "score-entity-id" plan)
                            ,"pre-deb"           : (URC_ScoreEntityMemberDebWeight
                                                       (at "score-entity-type" plan) (at "score-entity-id" plan))}
                        )
                        settle-plans
                    )
                )
            )
            (UDC_FVT|StakeSettleBundle settle-scores distinct-fvts settle-plans pre-nz-flags pre-member-debs)
        )
    )
    (defun URH_FvtStalePresentUsers:[string] (fvt-id:string)
        @doc "HEAVY sweep scan (M3 #12): the FVT's present users who have ≥1 deb-stale member — the exact set that \
            \ CC_Inject / the MTX|n|C_Inject defpact / CCp_InjectFixChunk must fix before injecting. Computes the \
            \ FVT's enabled members ONCE and reuses it across every present user (was O(users × ScoreEntityLink \
            \ scan) — the per-user re-scan a 50-user scale probe measured at ~2M gas; now O(scan + users))."
        (let
            (
                (members:[string] (URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
            )
            (filter (lambda (u:string) (URC_FvtUserHasStaleMemberIn fvt-id u members)) (URH_FvtPresentUsers fvt-id))
        )
    )
    ;; [URCi]   cost readers — single source for exec billing + INFO preview
    (defun URCi_Issue:object{IgnisCollectorV1.OutputCumulator} (owner-konto:string output:[string])
        (let ((r:module{IgnisCollectorV1} IGNIS)) (r::UDC_ConstructOutputCumulator GAS|ISSUE-FVT owner-konto (r::URC_IsVirtualGasZero) output)))
    (defun URCi_IssueStoa:decimal ()
        (let ((d:module{OuronetDalosV1} DALOS)) (d::UR_UsagePrice "smart")))
    (defun URCi_RotateOwnership:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string)
        (let ((r:module{IgnisCollectorV1} IGNIS)) (r::UDC_MediumCumulator (UR_FVT|OwnerKonto fvt-id))))
    (defun URCi_Control:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string)
        (let ((r:module{IgnisCollectorV1} IGNIS)) (r::UDC_MediumCumulator (UR_FVT|OwnerKonto fvt-id))))
    (defun URCi_SetCommonDenominator:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string])
        (let ((r:module{IgnisCollectorV1} IGNIS)) (r::UDC_ConstructOutputCumulator GAS|SET-COMMON-DENOMINATOR (UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)))
    (defun URCi_SetMosaic:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string])
        (let ((r:module{IgnisCollectorV1} IGNIS)) (r::UDC_ConstructOutputCumulator GAS|SET-MOSAIC (UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)))
    (defun URCi_SetSplitMode:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string])
        (let ((r:module{IgnisCollectorV1} IGNIS)) (r::UDC_ConstructOutputCumulator GAS|SET-SPLIT-MODE (UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)))
    (defun URCi_AddScoreEntity:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string])
        (let ((r:module{IgnisCollectorV1} IGNIS)) (r::UDC_ConstructOutputCumulator GAS|ADD-SCORE-ENTITY (UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)))
    (defun URCi_ToggleScoreEntityLink:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string])
        (let ((r:module{IgnisCollectorV1} IGNIS)) (r::UDC_ConstructOutputCumulator GAS|TOGGLE-SCORE-ENTITY-LINK (UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)))
    (defun URCi_IssueMultipletFamily:object{IgnisCollectorV1.OutputCumulator} (patron:string output:[string])
        (let ((r:module{IgnisCollectorV1} IGNIS)) (r::UDC_ConstructOutputCumulator GAS|ISSUE-MULTIPLET-FAMILY patron (r::URC_IsVirtualGasZero) output)))
    (defun URCi_AddRewardLink:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string])
        (let ((r:module{IgnisCollectorV1} IGNIS)) (r::UDC_ConstructOutputCumulator GAS|ADD-REWARD-LINK (UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)))
    (defun URCi_ToggleRewardLink:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string])
        (let ((r:module{IgnisCollectorV1} IGNIS)) (r::UDC_ConstructOutputCumulator GAS|TOGGLE-REWARD-LINK (UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)))
    (defun URCi_SetQualitySplit:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string])
        (let ((r:module{IgnisCollectorV1} IGNIS)) (r::UDC_ConstructOutputCumulator GAS|SET-QUALITY-SPLIT (UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)))
    (defun URCi_Inject:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string])
        @doc "GAS|INJECT gas leg (konto = FVT owner); shared by instant inject, stream inject, and inject-finalize."
        (let ((r:module{IgnisCollectorV1} IGNIS)) (r::UDC_ConstructOutputCumulator GAS|INJECT (UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)))
    (defun URCi_UnstaleMyScores:object{IgnisCollectorV1.OutputCumulator} (patron:string output:[string])
        @doc "GAS|UNSTALE gas leg (konto = patron); exec concats it with the per-fvt unstale walk."
        (let ((r:module{IgnisCollectorV1} IGNIS)) (r::UDC_ConstructOutputCumulator GAS|UNSTALE patron (r::URC_IsVirtualGasZero) output)))
    (defun URCi_Collect:object{IgnisCollectorV1.OutputCumulator} (fvt-id:string output:[string])
        @doc "GAS|COLLECT gas leg (konto = FVT owner); exec concats it with the forced-fix penalty leg and (triplet) the ATS ladder legs."
        (let ((r:module{IgnisCollectorV1} IGNIS)) (r::UDC_ConstructOutputCumulator GAS|COLLECT (UR_FVT|OwnerKonto fvt-id) (r::URC_IsVirtualGasZero) output)))
    ;; [URCi]   DSA royalty-disposal CUSTODY-move ifp readers — read-only mirror of the XE_*Royalty custody legs
    ;;   (the DSA A_*Royalty exec concats URCi_*Royalty gas leg with the FVT XE_*Royalty custody cumulator).
    ;;   The disposal amount/token are reconstructed from the live royalty pool balance + IGNIS-normalize decision.
    (defun URCi_WithdrawRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string destination:string)
        @doc "Read-only IGNIS ifp of the custody move in XE_WithdrawRoyalty: IGNIS-normalize leg (compress the \
            \ IGNIS royalty to OURO when reward-dptf is IGNIS, else none) + a TFT transfer of the normalized live \
            \ royalty balance from AQP|SC_NAME to <destination>."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-ORBR:module{OuroborosV1} OUROBOROS)
                ;;
                (royalty:decimal   (UR_FVT-RG|RoyaltyRewards fvt-id reward-dptf-id))
                (is-ignis:bool     (= reward-dptf-id (ref-DALOS::UR_IgnisID)))
                (token:string      (if is-ignis (ref-DALOS::UR_OuroborosID) reward-dptf-id))
                (amount:decimal    (if is-ignis (at 0 (ref-ORBR::URC_Compress royalty)) royalty))
                (xfer-type:integer (at "type" (ref-TFT::URC_TransferClasses token AQP|SC_NAME destination amount)))
            )
            (+ (if is-ignis (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ORBR::URCi_Compress AQP|SC_NAME royalty)) 0.0)
               (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                   (ref-TFT::URCi_TransferCumulator xfer-type token AQP|SC_NAME destination)))))
    (defun URCi_BurnRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string)
        @doc "Read-only IGNIS ifp of the custody burn in XE_BurnRoyalty: IGNIS-normalize leg (compress when the \
            \ reward-dptf is IGNIS, else none) + a DPTF burn of the normalized live royalty balance from AQP|SC_NAME."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ORBR:module{OuroborosV1} OUROBOROS)
                ;;
                (royalty:decimal (UR_FVT-RG|RoyaltyRewards fvt-id reward-dptf-id))
                (is-ignis:bool   (= reward-dptf-id (ref-DALOS::UR_IgnisID)))
                (token:string    (if is-ignis (ref-DALOS::UR_OuroborosID) reward-dptf-id))
            )
            (+ (if is-ignis (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ORBR::URCi_Compress AQP|SC_NAME royalty)) 0.0)
               (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_Burn token AQP|SC_NAME)))))
    (defun URCi_FuelRoyaltyCustody:decimal (fvt-id:string reward-dptf-id:string swpair:string)
        @doc "Read-only IGNIS ifp of the custody fuel in XE_FuelRoyalty: IGNIS-normalize leg (compress when the \
            \ reward-dptf is IGNIS, else none) + an SWPLC fuel of the normalized live royalty balance from AQP|SC_NAME \
            \ into <swpair> (amount in the normalized token's slot, 0 elsewhere; direct)."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-ORBR:module{OuroborosV1} OUROBOROS)
                (ref-SWP:module{SwapperV3} SWP)
                (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                ;;
                (royalty:decimal (UR_FVT-RG|RoyaltyRewards fvt-id reward-dptf-id))
                (is-ignis:bool   (= reward-dptf-id (ref-DALOS::UR_IgnisID)))
                (token:string    (if is-ignis (ref-DALOS::UR_OuroborosID) reward-dptf-id))
                (amount:decimal  (if is-ignis (at 0 (ref-ORBR::URC_Compress royalty)) royalty))
                (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                (input-amounts:[decimal] (map (lambda (t:string) (if (= t token) amount 0.0)) pool-tokens))
            )
            (+ (if is-ignis (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ORBR::URCi_Compress AQP|SC_NAME royalty)) 0.0)
               (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-SWPLC::URCi_Fuel AQP|SC_NAME swpair input-amounts true)))))
    ;; [URCi/URC]   CC_Collect FULL-cost readers — read-only mirror of the reward-payout leg (XI_TransferRewardDptfFromVault:
    ;;   plain single TFT transfer, or a MULTIPLET_BASE triplet Coil/Curl ladder, homogeneous or heterogeneous) + the
    ;;   Phase-7 forced-fix penalty + GAS|COLLECT. The payout is derived on the CURRENT (pre-drip) claimable state —
    ;;   exact for un-streamed / settled lanes (see URCi_CollectFull residual note).
    (defun URC_CollectXferIgnis:decimal (id:string patron:string amount:decimal)
        @doc "IGNIS ifp of one reward custody transfer AQP|SC_NAME -> patron of <amount> <id> (0 when amount<=0); \
            \ mirrors (if (> amt 0.0) (C_Transfer id AQP|SC_NAME patron amt true) (UC_EmptyOc))."
        (if (<= amount 0.0)
            0.0
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                    (ref-TFT:module{TrueFungibleTransferV1} TFT)
                )
                (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                    (ref-TFT::URCi_TransferCumulator
                        (at "type" (ref-TFT::URC_TransferClasses id AQP|SC_NAME patron amount))
                        id AQP|SC_NAME patron)))))
    (defun URC_HeterogeneousLaneRouteIgnis:decimal
        (patron:string fvt-id:string reward-dptf-id:string mf-id:string amt-b:decimal amt-s:decimal amt-g:decimal prec:integer)
        @doc "IGNIS ifp mirror of XI_1|HeterogeneousLaneRoute: pre-fund token-0 (two transfers) + Coil(total-t1) + Curl(total-t2)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-ATSU:module{AutostakeUsageV1} ATSU)
                (ref-ATS:module{AutostakeV2} ATS)
                (bs:[integer] (UR_FVT-QS|BronzeSplit fvt-id reward-dptf-id))
                (ss:[integer] (UR_FVT-QS|SilverSplit fvt-id reward-dptf-id))
                (gs:[integer] (UR_FVT-QS|GoldSplit fvt-id reward-dptf-id))
                (token-0:string (UR_FVT-MF|Token0Id mf-id))
                (ats-01:string (UR_FVT-MF|Ats01Id mf-id))
                (ats-12:string (UR_FVT-MF|Ats12Id mf-id))
                (b0:decimal (floor (/ (* amt-b (dec (at 0 bs))) 1000.0) prec))
                (b1:decimal (floor (/ (* amt-b (dec (at 1 bs))) 1000.0) prec))
                (s0:decimal (floor (/ (* amt-s (dec (at 0 ss))) 1000.0) prec))
                (s1:decimal (floor (/ (* amt-s (dec (at 1 ss))) 1000.0) prec))
                (g0:decimal (floor (/ (* amt-g (dec (at 0 gs))) 1000.0) prec))
                (g1:decimal (floor (/ (* amt-g (dec (at 1 gs))) 1000.0) prec))
                (total-t0:decimal (+ b0 (+ s0 g0)))
                (total-t1:decimal (+ b1 (+ s1 g1)))
                (total-t2:decimal (- (+ amt-b (+ amt-s amt-g)) (+ total-t0 total-t1)))
                (fund-12:decimal (+ total-t1 total-t2))
                (coil-ok:bool
                    (if (> total-t1 0.0)
                        (> (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 total-t1)) 0.0)
                        false))
                (curl-ok:bool
                    (if (> total-t2 0.0)
                        (let ((h1:object (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 total-t2)))
                            (if (> (at "rbt-amount" h1) 0.0)
                                (> (at "rbt-amount"
                                        (ref-ATS::URC_RewardBearingTokenAmounts ats-12 (at "rbt-id" h1) (at "rbt-amount" h1)))
                                   0.0)
                                false))
                        false))
            )
            (fold (+) 0.0
                [ (URC_CollectXferIgnis token-0 patron total-t0)
                  (URC_CollectXferIgnis token-0 patron fund-12)
                  (if coil-ok (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_Coil patron ats-01 token-0 total-t1)) 0.0)
                  (if curl-ok (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_Curl patron ats-01 ats-12 token-0 total-t2)) 0.0)
                ])))
    (defun URC_CollectTransferLegIgnis:decimal
        (patron:string pool-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "IGNIS ifp mirror of XI_TransferRewardDptfFromVault (PHASE 1.1 collect payout leg)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-ATSU:module{AutostakeUsageV1} ATSU)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (reward-kind:string (UR_FVT-RG|RewardKind fvt-id reward-dptf-id))
                (payout:decimal (URC_CollectClaimableRewards patron pool-id fvt-id score-entity-type score-entity-id reward-dptf-id))
            )
            (if (<= payout 0.0)
                0.0
                (if (and (= reward-kind CT_REWARD_KIND_MULTIPLET_BASE) (= score-entity-type CT_SCORE_ENTITY_TRIPLET))
                    (let*
                        (
                            (mf-id:string (UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
                            (lanes:object (URC_ComputeTripletLanes patron pool-id score-entity-id))
                            (lane-b:decimal (at "lane-b" lanes))
                            (lane-s:decimal (at "lane-s" lanes))
                            (lane-g:decimal (at "lane-g" lanes))
                            (w-total:decimal (at "w-user" lanes))
                            (token-0:string (UR_FVT-MF|Token0Id mf-id))
                            (ats-01:string (UR_FVT-MF|Ats01Id mf-id))
                            (ats-12:string (UR_FVT-MF|Ats12Id mf-id))
                            (prec:integer (ref-DPTF::UR_Decimals token-0))
                            (mode:string (UR_FVT-QS|Mode fvt-id reward-dptf-id))
                            (amt-b:decimal (if (> w-total 0.0) (floor (* payout (/ lane-b w-total)) prec) 0.0))
                            (amt-s:decimal (if (> w-total 0.0) (floor (* payout (/ lane-s w-total)) prec) 0.0))
                            (amt-g:decimal (- payout (+ amt-b amt-s)))
                            (fund-sg:decimal (+ amt-s amt-g))
                            (coil-s-ok:bool
                                (if (> amt-s 0.0)
                                    (> (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 amt-s)) 0.0)
                                    false))
                            (curl-g-ok:bool
                                (if (> amt-g 0.0)
                                    (let ((h1:object (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 amt-g)))
                                        (if (> (at "rbt-amount" h1) 0.0)
                                            (> (at "rbt-amount"
                                                    (ref-ATS::URC_RewardBearingTokenAmounts ats-12 (at "rbt-id" h1) (at "rbt-amount" h1)))
                                               0.0)
                                            false))
                                    false))
                        )
                        (if (= mode CT_REWARD_MODE_HETEROGENEOUS)
                            (URC_HeterogeneousLaneRouteIgnis patron fvt-id reward-dptf-id mf-id amt-b amt-s amt-g prec)
                            (fold (+) 0.0
                                [ (URC_CollectXferIgnis token-0 patron amt-b)
                                  (URC_CollectXferIgnis token-0 patron fund-sg)
                                  (if coil-s-ok (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_Coil patron ats-01 token-0 amt-s)) 0.0)
                                  (if curl-g-ok (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-ATSU::URCi_Curl patron ats-01 ats-12 token-0 amt-g)) 0.0)
                                ])))
                    (URC_CollectXferIgnis reward-dptf-id patron payout)))))
    (defun URC_CollectForcedFixIgnis:decimal (patron:string fvt-id:string reward-dptf-id:string)
        @doc "IGNIS ifp mirror of CC_Collect PHASE 7 forced-fix penalty: (ffc x CT_FORCED_FIX_RATE / patron-discount) \
            \ gated by the virtual-gas toggle; 0 when ffc<=0."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ffc:integer (UR_FVT-FFC|Count fvt-id reward-dptf-id patron))
            )
            (if (<= ffc 0)
                0.0
                (UC_GasPrice (/ (* (dec ffc) CT_FORCED_FIX_RATE) (ref-DALOS::URC_IgnisGasDiscount patron))
                             (ref-IGNIS::URC_IsVirtualGasZero)))))
    (defun URCi_CollectFull:decimal
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "FULL reconstructed IGNIS ifp of CC_Collect = reward-payout leg (URC_CollectTransferLegIgnis) + Phase-7 \
            \ forced-fix penalty (URC_CollectForcedFixIgnis) + GAS|COLLECT. Residual: the payout is read pre-drip, so \
            \ a lane carrying a LIVE stream (whose exec drip vests extra reward before payout) can shift the transfer \
            \ tier — exact only for un-streamed / already-settled lanes."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                ;;
                (pool-id:string
                    (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                        (ref-SCR::UR_SCR|ScoreAqpoolLink (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                        (ref-SCR::UR_SCR|ScoreAqpoolLink score-entity-id)))
            )
            (fold (+) 0.0
                [ (URC_CollectTransferLegIgnis patron pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
                  (URC_CollectForcedFixIgnis patron fvt-id reward-dptf-id)
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (URCi_Collect fvt-id [fvt-id score-entity-id reward-dptf-id]))
                ])))
    (defun URC_TierMedium:decimal ()
        @doc "IGNIS tier 'ignis|medium' behind the virtual-gas toggle."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS))
            (UC_GasPrice (ref-DALOS::UR_UsagePrice "ignis|medium") (ref-IGNIS::URC_IsVirtualGasZero)))
    )
    (defun URC_TierBiggest:decimal ()
        @doc "IGNIS tier 'ignis|biggest' behind the virtual-gas toggle."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS) (ref-DALOS:module{OuronetDalosV1} DALOS))
            (UC_GasPrice (ref-DALOS::UR_UsagePrice "ignis|biggest") (ref-IGNIS::URC_IsVirtualGasZero)))
    )
    (defun URC_TierFixed:decimal (gas-cost:decimal)
        @doc "A FIXED IGNIS gas cost behind the virtual-gas toggle."
        (let ((ref-IGNIS:module{IgnisCollectorV1} IGNIS))
            (UC_GasPrice gas-cost (ref-IGNIS::URC_IsVirtualGasZero)))
    )
    (defun URC_StakeScoreDeltaSum:decimal (pool-id:string)
        @doc "Phase-4 leg: Σ SCORE.URC_StakeScoreDeltaIgnisUnit over POOL.URC_PoolActiveScoreIds (raw, ungated)."
        (fold (+) 0.0
            (map (lambda (sid:string) (AQP-SCORE.URC_StakeScoreDeltaIgnisUnit sid))
                 (AQP-POOL.URC_PoolActiveScoreIds pool-id)))
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
    (defun URCi_TrueFungibleStakeFlow:decimal
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Toggled total IGNIS IFP of CC_TrueFungibleStakeFlow. Legs: transfer + tracker + rollup \
            \ + RPS-settle + anchor-refresh(ANK per-unit + XB flat) + score-delta + book + checkpoint. \
            \ direction=true stake (owner→vault), false unstake (vault→owner)."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (bundle           (URHC_BuildStakeSettleBundle pool-id beneficiary-id))
                (settle-scores:[string] (at "settle-scores" bundle))
                (distinct-fvts:[string] (at "distinct-fvts" bundle))
                (vault:string     AQP-POOL.AQP|SC_NAME)
                (sender:string    (if direction owner-id vault))
                (receiver:string  (if direction vault owner-id))
                (xfer-type:integer (at "type" (TFT.URC_TransferClasses dptf-id sender receiver amount)))
                (n-live:integer   (length (AQP-ANK.UR_ANK|AnchorsForAsset dptf-id)))
            )
            (fold (+) 0.0
                [ (URC_TierFixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                     ;; 1.1 custody transfer
                      (TFT.URCi_TransferCumulator xfer-type dptf-id sender receiver)))
                  (URC_TierMedium)                                                                 ;; 1.2 pool tracker (medium ×1)
                  (URC_TierBiggest)                                                                ;; 1.3 ben rollup   (biggest ×1)
                  (URC_TierFixed (URC_SettleStakePendingIgnis settle-scores distinct-fvts))        ;; 2   RPS settle
                  (URC_TierFixed (AQP-ANK.URC_TrueFungibleStakeAnchorRefreshIgnis n-live))         ;; 3.1a ANK anchor refresh
                  (URC_TierBiggest)                                                                ;; 3.1b XB sync-count (biggest ×1)
                  (URC_TierFixed (URC_StakeScoreDeltaSum pool-id))                                 ;; 4   score delta
                  (URC_TierFixed (URC_BookStakeUnclaimedIgnis distinct-fvts))                      ;; 5.1 book unclaimed
                  (URC_TierFixed (URC_CheckpointStakeRpsIgnis))                                    ;; 5.2 checkpoint
                ])
        )
    )
    (defun URCi_OrtoFungibleStakeFlow:decimal
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] direction:bool)
        @doc "Toggled total IGNIS IFP of CC_OrtoFungibleStakeFlow. Legs: transfer(DPOF, direction- \
            \ INDEPENDENT) + tracker(medium × |nonces|) + RPS-settle + score-delta(class ∈ {0,2}) + \
            \ book + checkpoint. NO 1.3 rollup, NO anchor leg."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (bundle           (URHC_BuildStakeSettleBundle pool-id beneficiary-id))
                (settle-scores:[string] (at "settle-scores" bundle))
                (distinct-fvts:[string] (at "distinct-fvts" bundle))
                (nn:decimal       (dec (length nonces)))
            )
            (fold (+) 0.0
                [ (URC_TierFixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                     ;; 1.1 transfer (dir-indep)
                      (DPOF.URCi_MoveCumulator dpof-id nonces false)))
                  (* (URC_TierMedium) nn)                                                          ;; 1.2 tracker (medium × |nonces|)
                  (URC_TierFixed (URC_SettleStakePendingIgnis settle-scores distinct-fvts))        ;; 2   RPS settle
                  (URC_TierFixed (URC_StakeScoreDeltaSumForClasses pool-id [0 2]))                 ;; 4   score delta (class ∈ {0,2})
                  (URC_TierFixed (URC_BookStakeUnclaimedIgnis distinct-fvts))                      ;; 5.1 book unclaimed
                  (URC_TierFixed (URC_CheckpointStakeRpsIgnis))                                    ;; 5.2 checkpoint
                ])
        )
    )
    (defun URCi_CollectableStakeFlow:decimal
        (pool-id:string owner-id:string beneficiary-id:string collectable-id:string son:bool nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Toggled total IGNIS IFP of CC_CollectableStakeFlow (SF son=true class-3 / NF son=false \
            \ class-4). Legs: transfer(DPDC-T, direction-dependent) + tracker(medium × |nonces|) + \
            \ rollup(medium × |nonces|) + RPS-settle + anchor(FLAT medium + biggest) + score-delta \
            \ (class == son?3:4) + book + checkpoint. nonce-amounts is caller-supplied."
        (let*
            (
                (ref-I|OURONET:module{OuronetInfoV1} IGNIS)
                (bundle           (URHC_BuildStakeSettleBundle pool-id beneficiary-id))
                (settle-scores:[string] (at "settle-scores" bundle))
                (distinct-fvts:[string] (at "distinct-fvts" bundle))
                (vault:string     AQP-POOL.AQP|SC_NAME)
                (sender:string    (if direction owner-id vault))
                (receiver:string  (if direction vault owner-id))
                (nn:decimal       (dec (length nonces)))
                (tgt-class:integer (if son 3 4))
            )
            (fold (+) 0.0
                [ (URC_TierFixed (ref-I|OURONET::OI|UC_IfpFromOutputCumulator                     ;; 1.1 transfer (dir-dep)
                      (DPDC-T.URCi_MultiTransferCumulator [collectable-id] [son] sender receiver [nonces] [nonce-amounts])))
                  (* (URC_TierMedium) nn)                                                          ;; 1.2 tracker (medium × |nonces|)
                  (* (URC_TierMedium) nn)                                                          ;; 1.3 rollup  (medium × |nonces|)
                  (URC_TierFixed (URC_SettleStakePendingIgnis settle-scores distinct-fvts))        ;; 2   RPS settle
                  (URC_TierMedium)                                                                 ;; 3 anchor flat medium
                  (URC_TierBiggest)                                                                ;; 3 anchor flat biggest
                  (URC_TierFixed (URC_StakeScoreDeltaSumForClasses pool-id [tgt-class]))           ;; 4 score delta (class == son?3:4)
                  (URC_TierFixed (URC_BookStakeUnclaimedIgnis distinct-fvts))                      ;; 5.1 book unclaimed
                  (URC_TierFixed (URC_CheckpointStakeRpsIgnis))                                    ;; 5.2 checkpoint
                ])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;; [UEV] enforce
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
    (defun UEV_SetMosaicContext (fvt-id:string mosaic:bool)
        @doc "C_SetMosaic: owner, can-upgrade, zero member-link-count."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                (can-upgrade:bool (UR_FVT|CanUpgrade fvt-id))
            )
            (enforce can-upgrade "FVT mosaic update requires can-upgrade true")
            (enforce
                (= (UR_FVT|MemberLinkCount fvt-id) 0)
                "Cannot change mosaic while ScoreEntityLink rows exist"
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
        )
    )
    (defun UEV_AddScoreEntityContext
        (fvt-id:string score-entity-type:integer score-entity-id:string swpair:string ghost-weight:decimal)
        @doc "C_AddScoreEntity unified admission: type 1 = score rules; type 3 = triplet rules + SCR fvt-links."
        (if (= score-entity-type CT_SCORE_ENTITY_SCORE)
            (UEV_AddScoreEntityScoreContext fvt-id score-entity-id swpair ghost-weight)
            (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                (UEV_AddScoreEntityTripletContext fvt-id score-entity-id swpair ghost-weight)
                (enforce false "score-entity-type must be 1 (score) or 3 (triplet)")
            )
        )
    )
    (defun UEV_AddScoreEntityScoreContext
        (fvt-id:string score-id:string swpair:string ghost-weight:decimal)
        @doc "Validates the context for linking a SCORE entity to <fvt-id>: score-owner matches FVT-owner, \
            \ membership mode admits scores (or mosaic), no pre-existing link, score class matches FVT class, \
            \ correct <swpair>, and the class-0 farm rule (lp-denominator = common-denominator + positive \
            \ ghost-weight) vs the vault/treasury rule (swpair | + zero ghost-weight). Enforces FVT-owner ownership."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (fvt-owner:string (UR_FVT|OwnerKonto fvt-id))
                (fvt-class:integer (UR_FVT|FvtClass fvt-id))
                (score-owner:string (ref-SCR::UR_SCR|ScoreOwnerKonto score-id))
                (score-class:integer (ref-SCR::UR_SCR|ScoreClass score-id))
                (fvt-link:string (ref-SCR::UR_SCR|ScoreFvtLink score-id))
                (aqpool-link:string (ref-SCR::UR_SCR|ScoreAqpoolLink score-id))
                (lp-denom:string (ref-SCR::UR_SCR|ScoreLpDenominator score-id))
                (common-denom:string (UR_FVT|CommonDenominator fvt-id))
                (expected-swpair:string (URC_ResolveScoreEntitySwpair CT_SCORE_ENTITY_SCORE score-id fvt-class))
            )
            (enforce (= score-owner fvt-owner) "Score owner must match FVT owner")
            (enforce
                (or (UR_FVT|Mosaic fvt-id)
                    (let ((mode:string (UR_FVT|MembershipMode fvt-id)))
                        (or (= mode CT_MEMBERSHIP_MODE_BAR) (= mode CT_MEMBERSHIP_MODE_SCORE))))
                "Non-mosaic FVT locked to score membership only")
            (enforce
                (fold (and) true
                    [(not (URC_FvtScoreEntityLinkRowExists fvt-id score-id))
                     (= fvt-link BAR) (!= aqpool-link BAR)
                     (URC_ScoreClassMatchesFvtClass fvt-class score-class)
                     (= swpair expected-swpair)])
                "Invalid AddScoreEntity score: row exists, links, class, or swpair mismatch")
            (if (= fvt-class 0)
                (enforce (fold (and) true [(= lp-denom common-denom) (> ghost-weight 0.0)])
                    "Farm score: lp-denominator and ghost weight required")
                (enforce (fold (and) true [(= swpair "|") (= ghost-weight 0.0)])
                    "Vault/Treasury score: swpair | and zero ghost weight"))
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
    )
    (defun UEV_AddScoreEntityTripletContext
        (fvt-id:string triplet-id:string swpair:string ghost-weight:decimal)
        @doc "Validates the context for linking a TRIPLET entity to <fvt-id>: triplet is issued with a category \
            \ matching the FVT class, membership mode admits the triplet kind (true vs standard, or mosaic), \
            \ silver-owner matches FVT-owner, no pre-existing link, silver has an aqpool link, all three \
            \ (bronze/silver/golden) score fvt-links are BAR, correct <swpair>, and the class-0 farm vs \
            \ vault/treasury weight rule. Enforces FVT-owner ownership."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (fvt-owner:string (UR_FVT|OwnerKonto fvt-id))
                (fvt-class:integer (UR_FVT|FvtClass fvt-id))
                (bronze-id:string (ref-SCR::UR_SCR|TripletBronzeScoreId triplet-id))
                (silver-id:string (ref-SCR::UR_SCR|TripletSilverScoreId triplet-id))
                (golden-id:string (ref-SCR::UR_SCR|TripletGoldenScoreId triplet-id))
                (triplet-cat:string (ref-SCR::UR_SCR|TripletCategory triplet-id))
                (is-true-triplet:bool (ref-SCR::UR_SCR|TripletTrueTriplet triplet-id))
                (silver-owner:string (ref-SCR::UR_SCR|ScoreOwnerKonto silver-id))
                (silver-aqpool:string (ref-SCR::UR_SCR|ScoreAqpoolLink silver-id))
                (common-denom:string (UR_FVT|CommonDenominator fvt-id))
                (silver-lp-denom:string (ref-SCR::UR_SCR|ScoreLpDenominator silver-id))
                (expected-swpair:string (URC_ResolveScoreEntitySwpair CT_SCORE_ENTITY_TRIPLET triplet-id fvt-class))
            )
            (enforce (ref-SCR::URC_TripletExists triplet-id) "Triplet must be issued in AQP-SCORE")
            (enforce (ref-SCR::URC_TripletCategoryMatchesFvtClass triplet-cat fvt-class) "Triplet category must match FVT class")
            (enforce
                (or (UR_FVT|Mosaic fvt-id)
                    (let ((mode:string (UR_FVT|MembershipMode fvt-id)))
                        (or (= mode CT_MEMBERSHIP_MODE_BAR)
                            (and (= mode CT_MEMBERSHIP_MODE_TRUE_TRIPLET) is-true-triplet)
                            (and (= mode CT_MEMBERSHIP_MODE_STANDARD_TRIPLET) (not is-true-triplet)))))
                "Non-mosaic FVT membership mode mismatch for triplet admission")
            (enforce
                (fold (and) true
                    [(= silver-owner fvt-owner)
                     (not (URC_FvtScoreEntityLinkRowExists fvt-id triplet-id))
                     (!= silver-aqpool BAR) (= swpair expected-swpair)
                     (= (ref-SCR::UR_SCR|ScoreFvtLink bronze-id) BAR)
                     (= (ref-SCR::UR_SCR|ScoreFvtLink silver-id) BAR)
                     (= (ref-SCR::UR_SCR|ScoreFvtLink golden-id) BAR)])
                "Invalid AddScoreEntity triplet: row exists, links, or swpair mismatch")
            (if (= fvt-class 0)
                (enforce (fold (and) true [(= silver-lp-denom common-denom) (> ghost-weight 0.0)])
                    "Farm triplet: lp-denominator and ghost weight required")
                (enforce (fold (and) true [(= swpair "|") (= ghost-weight 0.0)])
                    "Vault/Treasury triplet: swpair | and zero ghost weight"))
            (ref-DALOS::CAP_EnforceAccountOwnership fvt-owner)
        )
    )
    (defun UEV_IssueMultipletFamilyContext
        (
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
        )
        @doc "C_IssueMultipletFamily: distinct issued DPTF ids, distinct ATS pairs; ATS ladder must match Coil/Curl chain."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-ATS:module{AutostakeV2} ATS)
            )
            (enforce
                (ref-DPTF::URC_IzRBTg ats-0-1-id token-1-id)
                "MultipletFamily token-1 must be reward-bearing on first ATS pair (Coil output)"
            )
            (enforce
                (ref-DPTF::URC_IzRBTg ats-1-2-id token-2-id)
                "MultipletFamily token-2 must be reward-bearing on second ATS pair (Curl output)"
            )
            (enforce
                (fold (and) true
                    [
                        (!= token-0-id token-1-id)
                        (!= token-1-id token-2-id)
                        (!= token-0-id token-2-id)
                        (!= ats-0-1-id BAR)
                        (!= ats-1-2-id BAR)
                        (!= ats-0-1-id ats-1-2-id)
                    ]
                )
                "Invalid MultipletFamily issue: tokens and ATS pairs must be distinct"
            )
            (ref-DPTF::UEV_id token-0-id)
            (ref-DPTF::UEV_id token-1-id)
            (ref-DPTF::UEV_id token-2-id)
            (ref-ATS::UEV_id ats-0-1-id)
            (ref-ATS::UEV_id ats-1-2-id)
            (ref-ATS::UEV_RewardTokenExistance ats-0-1-id token-0-id true)
            (ref-ATS::UEV_RewardTokenExistance ats-1-2-id token-1-id true)
        )
    )
    (defun UEV_InjectContext
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "C_Inject: patron account, issued reward DPTF, reward-enabled row, positive amount. \
            \ Escrow-on-empty: the inject denominator is NO LONGER required to be positive — a zero-denominator \
            \ inject (no stakers) is accepted and its amount is held as zombie-rewards (limbo), to be distributed \
            \ by the next non-zero inject. The zero/non-zero split is handled in XI_FvtInjectCore (farm S and \
            \ vault deb-sum are both computed there); this defcap only validates the token + amount + row."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
            )
            (enforce (not (UR_FVT|VacateFrozen fvt-id)) "FVT is frozen: a pool it serves is mid-vacate")
            (enforce (> amount 0.0) "Inject amount must be positive")
            (enforce (URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) "Reward link row must exist")
            (enforce (UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id) "Reward token is disabled for inject")
            (ref-DALOS::UEV_EnforceAccountExists patron)
            (ref-DPTF::UEV_id reward-dptf-id)
            (ref-DPTF::UEV_Amount reward-dptf-id amount)
        )
    )
    (defun UEV_StreamParams:bool
        (reward-dptf-id:string amount:decimal duration:integer)
        @doc "Count-INDEPENDENT part of the streamed-inject guard (defcap-safe — no post-drip state): duration in \
            \ [STREAM_MIN_DURATION, STREAM_MAX_DURATION] and a minimum release rate amount/duration >= \
            \ STREAM_MIN_UPS * 10^(-reward-decimals) (precision-normalized via exact integer pow, so the floor is \
            \ uniform across token decimals; 1e-5/sec for a 12-dp token). The count-DEPENDENT slot-cap check lives \
            \ in XI_FvtAddStream AFTER the drip — a finished stream frees its slot only once the drip prunes it."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (reward-dec:integer (ref-DPTF::UR_Decimals reward-dptf-id))
                (min-rate:decimal (/ (dec STREAM_MIN_UPS) (dec (^ 10 reward-dec))))
                (rate:decimal (/ amount (dec duration)))
            )
            (enforce
                (fold (and) true
                    [ (>= duration STREAM_MIN_DURATION)
                      (<= duration STREAM_MAX_DURATION)
                      (>= rate min-rate) ])
                "FVT|Stream: duration must be 1h..365d and rate >= STREAM_MIN_UPS/sec (raise amount or shorten duration)")
        )
    )
    (defun UEV_CollectContext
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "CC_Collect: dispatch by score-entity-type; MULTIPLET_BASE triplet collect requires matching global."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (reward-kind:string (UR_FVT-RG|RewardKind fvt-id reward-dptf-id))
                ;; the score's employing pool (triplet ⇒ silver leg's pool — mirrors CC_Collect's resolution)
                (pool-id:string
                    (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                        (ref-SCR::UR_SCR|ScoreAqpoolLink (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                        (ref-SCR::UR_SCR|ScoreAqpoolLink score-entity-id)))
            )
            ;; sweep D3: collect is frozen while a re-score sweep runs on the pool (the aggregate-promile is in
            ;; flux; a mid-sweep collect on an unswept holder would refresh deb against a stale-high aggregate).
            (enforce (not (ref-AQP::UR_AQP|PoolSweepInProgress pool-id))
                "Collect is frozen while a re-score sweep is in progress on this pool")
            (enforce (not (UR_FVT|VacateFrozen fvt-id)) "FVT is frozen: a pool it serves is mid-vacate")
            (enforce (URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) "Reward link row must exist")
            (enforce (UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id) "Reward token is disabled for collect")
            (enforce (URC_FvtScoreEntityLinkRowExists fvt-id score-entity-id) "ScoreEntityLink row must exist")
            (enforce (UR_FVT-SEL|Enabled fvt-id score-entity-id) "ScoreEntityLink must be enabled for collect")
            (enforce (= score-entity-type (UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id)) "score-entity-type mismatch")
            (if (and (= reward-kind CT_REWARD_KIND_MULTIPLET_BASE) (= score-entity-type CT_SCORE_ENTITY_TRIPLET))
                (enforce
                    (fold (and) true
                        [
                            (!= (UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id) BAR)
                            (URC_MultipletFamilyExists (UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
                            (UR_FVT-MF|Active (UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
                        ]
                    )
                    "MULTIPLET_BASE collect requires active MultipletFamily on global row"
                )
                true
            )
            (ref-DALOS::CAP_EnforceAccountOwnership patron)
            (ref-DPTF::UEV_id reward-dptf-id)
        )
    )
    (defun UEV_AddRewardLinkContext
        (fvt-id:string reward-dptf-id:string reward-kind:string multiplet-family-id:string)
        @doc "C_AddRewardLink admission: one RPS|Global row per (fvt, dptf). multiplet-family-id BAR = plain-only metadata; \
            \ F|… registers ladder for triplet-anchor collect (score anchors still plain). Kind derived in C_AddRewardLink."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
            )
            (enforce
                (not (URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id))
                "Reward link row already exists for this FVT and DPTF"
            )
            (if (= reward-kind CT_REWARD_KIND_MULTIPLET_BASE)
                (enforce
                    (fold (and) true
                        [
                            (!= multiplet-family-id BAR)
                            (URC_MultipletFamilyExists multiplet-family-id)
                            (UR_FVT-MF|Active multiplet-family-id)
                            (= reward-dptf-id (UR_FVT-MF|Token0Id multiplet-family-id))
                        ]
                    )
                    "MULTIPLET_BASE reward requires active MultipletFamily with reward-dptf-id = token-0-id"
                )
                (enforce
                    (and (= reward-kind CT_REWARD_KIND_PLAIN) (= multiplet-family-id BAR))
                    "PLAIN reward requires reward-kind PLAIN and multiplet-family-id BAR"
                )
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (ref-DPTF::UEV_id reward-dptf-id)
        )
    )
    (defun UEV_QualitySplitContext
        (fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
        @doc "C_SetQualitySplit admission: the reward link must exist and be MULTIPLET_BASE with an active family \
            \ (the split only means anything for a triplet ladder). mode in {HOMOGENEOUS, HETEROGENEOUS}. In \
            \ HETEROGENEOUS mode each lane row is [to-t0 to-t1 to-t2] of exactly 3 non-negative per-mille weights \
            \ summing to 1000; HOMOGENEOUS ignores the rows. Owner-gated."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                ;;
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                (heterogeneous:bool (= mode CT_REWARD_MODE_HETEROGENEOUS))
            )
            ;; 1) the reward link must exist and be a MULTIPLET_BASE triplet ladder
            (enforce (URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) "Reward link row must exist")
            (enforce
                (fold (and) true
                    [
                        (= (UR_FVT-RG|RewardKind fvt-id reward-dptf-id) CT_REWARD_KIND_MULTIPLET_BASE)
                        (URC_MultipletFamilyExists (UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
                        (UR_FVT-MF|Active (UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
                    ]
                )
                "Quality split requires a MULTIPLET_BASE reward with an active MultipletFamily"
            )
            ;; 2) mode is one of the two known modes
            (enforce
                (or (= mode CT_REWARD_MODE_HOMOGENEOUS) heterogeneous)
                "mode must be HOMOGENEOUS or HETEROGENEOUS"
            )
            ;; 3) in heterogeneous mode each lane row = 3 non-negative per-mille weights summing to 1000
            (if heterogeneous
                (enforce
                    (fold (and) true
                        [
                            (UC_PerMilleRow bronze-split)
                            (UC_PerMilleRow silver-split)
                            (UC_PerMilleRow gold-split)
                        ]
                    )
                    "Each lane split must be [to-t0 to-t1 to-t2] non-negative per-mille summing to 1000"
                )
                true
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
        )
    )
    (defun UEV_SetCommonDenominatorContext (fvt-id:string common-denominator:string)
        @doc "C_SetCommonDenominator: farm only, can-upgrade, no ScoreEntityLinks yet, valid DPTF id."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                ;;
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                (can-upgrade:bool (UR_FVT|CanUpgrade fvt-id))
                (fvt-class:integer (UR_FVT|FvtClass fvt-id))
            )
            (enforce can-upgrade "SetCommonDenominator requires can-upgrade true")
            (enforce (= fvt-class 0) "SetCommonDenominator applies to farm (class 0) FVT only")
            (enforce
                (not (URC_FvtHasScoreEntityLinks fvt-id))
                "Cannot change common-denominator after ScoreEntityLink rows exist"
            )
            (enforce
                (fold (and) true
                    [
                        (!= common-denominator BAR)
                        (!= common-denominator "|")
                    ]
                )
                "common-denominator must be a full native DPTF id"
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (ref-DPTF::UEV_id common-denominator)
        )
    )
    ;;{5.5}  Write [W]
    ;; [W]   write
    ;; Five blocks — one per deftable (table order). Within each block: WI → WW → WU → WU2+ (only when needed).
    ;; WU lists every schema field: defun when used; comment when [.], select key, or mutates via WW_*.
    ;;
    (defun WI_Fvt:string
        (fvt-id:string row:object{FVT|Schema})
        @doc "Insert FVT|T full row (issue only)."
        (require-capability (SECURE))
        (insert FVT|T fvt-id row)
    )
    ;; WW_Fvt — not used: issue path is WI_Fvt; other paths use WU_*.
    ;; WU_Fvt|FvtClass — not mutable [.]
    (defun WU_Fvt|OwnerKonto:string
        (fvt-id:string owner-konto:string)
        @doc "Update owner-konto on FVT|T."
        (require-capability (SECURE))
        (update FVT|T fvt-id {"owner-konto": owner-konto})
    )
    (defun WU2_Fvt|Control:string
        (fvt-id:string can-upgrade:bool can-change-owner:bool)
        @doc "Update can-upgrade and can-change-owner on FVT|T."
        (require-capability (SECURE))
        (update FVT|T fvt-id
            {"can-upgrade": can-upgrade, "can-change-owner": can-change-owner}
        )
    )
    ;; WU_Fvt|CanUpgrade — not used: mutates via WU2_Fvt|Control.
    ;; WU_Fvt|CanChangeOwner — not used: mutates via WU2_Fvt|Control.
    (defun WU_Fvt|CommonDenominator:string
        (fvt-id:string common-denominator:string)
        @doc "Update common-denominator on FVT|T."
        (require-capability (SECURE))
        (update FVT|T fvt-id {"common-denominator": common-denominator})
    )
    (defun WU_Fvt|TotalGhostTvlWeight:string
        (fvt-id:string total-ghost-tvl-weight:decimal)
        @doc "Update total-ghost-tvl-weight (farm S) on FVT|T."
        (require-capability (SECURE))
        (update FVT|T fvt-id {"total-ghost-tvl-weight": total-ghost-tvl-weight})
    )
    ;; WU_Fvt|TotalBaseScore — not yet written in this module.
    ;; WU_Fvt|TotalBoostedScore — not yet written in this module.
    (defun WU_Fvt|TotalDebScore:string
        (fvt-id:string total-deb-score:decimal)
        @doc "Update total-deb-score mirror on FVT|T (vault/treasury inject denominator reporting)."
        (require-capability (SECURE))
        (update FVT|T fvt-id {"total-deb-score": total-deb-score})
    )
    ;; WU_Fvt|TotalNzsCount — not yet written in this module.
    (defun WU_Fvt|EnabledRewardCount:string
        (fvt-id:string enabled-reward-count:integer)
        @doc "Update enabled-reward-count on FVT|T."
        (require-capability (SECURE))
        (update FVT|T fvt-id {"enabled-reward-count": enabled-reward-count})
    )
    (defun WU_Fvt|MemberLinkCount:string
        (fvt-id:string member-link-count:integer)
        @doc "Update member-link-count on FVT|T (C_AddScoreEntity / SetMosaic gate)."
        (require-capability (SECURE))
        (update FVT|T fvt-id {"member-link-count": member-link-count})
    )
    (defun WU_FvtVacateFreeze:string (fvt-id:string frozen:bool)
        @doc "Set the FVT vacate-frozen flag on FVT|T|VacateFreeze (write = upsert; reader defaults false)."
        (require-capability (SECURE))
        (write FVT|T|VacateFreeze fvt-id {"frozen": frozen})
    )
    (defun WU_FvtSweepProgress:string (anchor-id:string total:integer offset:integer active:bool)
        @doc "Upsert the paginated re-score sweep cursor on FVT|T|SweepProgress (write = upsert; reader defaults \
            \ to an inactive empty cursor). SECURE."
        (require-capability (SECURE))
        (write FVT|T|SweepProgress anchor-id {"total": total, "offset": offset, "active": active})
    )
    (defun WU_Fvt|Mosaic:string
        (fvt-id:string mosaic:bool)
        @doc "Update mosaic on FVT|T (C_SetMosaic only when no member links)."
        (require-capability (SECURE))
        (update FVT|T fvt-id {"mosaic": mosaic})
    )
    (defun WU2_Fvt|MosaicPolicy:string
        (fvt-id:string mosaic:bool membership-mode:string)
        @doc "Update mosaic and membership-mode together (C_SetMosaic)."
        (require-capability (SECURE))
        (update FVT|T fvt-id {"mosaic": mosaic, "membership-mode": membership-mode})
    )
    (defun WU_Fvt|MembershipMode:string
        (fvt-id:string membership-mode:string)
        @doc "Lock membership-mode on first non-mosaic admission."
        (require-capability (SECURE))
        (update FVT|T fvt-id {"membership-mode": membership-mode})
    )
    (defun WU_Fvt|OracleOn:string
        (fvt-id:string oracle-on:bool)
        @doc "DSA: toggle the node/uptime oracle on this FVT."
        (require-capability (SECURE))
        (update FVT|T fvt-id {"oracle-on": oracle-on})
    )
    (defun WU_Fvt|SplitMode:string
        (fvt-id:string split-mode:string)
        @doc "Update the farm reward-split mode on FVT|T (C_SetSplitMode; farm-only, freely mutable)."
        (require-capability (SECURE))
        (update FVT|T fvt-id {"split-mode": split-mode})
    )
    ;; WU_Fvt|FvtId — select key; WU not needed.
    ;;
    (defun WI_ScoreEntityLink:string
        (fvt-id:string score-entity-id:string row:object{FVT|ScoreEntityLink})
        @doc "Insert FVT|T|ScoreEntityLink full row (C_AddScoreEntity admission)."
        (require-capability (SECURE))
        (insert FVT|T|ScoreEntityLink (UCk_ScoreEntityLink fvt-id score-entity-id) row)
    )
    (defun WU_ScoreEntityLink|Enabled:string
        (fvt-id:string score-entity-id:string enabled:bool)
        @doc "Update enabled on FVT|T|ScoreEntityLink."
        (require-capability (SECURE))
        (update FVT|T|ScoreEntityLink (UCk_ScoreEntityLink fvt-id score-entity-id) {"enabled": enabled})
    )
    (defun WU_ScoreEntityLink|GhostTvlWeight:string
        (fvt-id:string score-entity-id:string ghost-tvl-weight:decimal)
        @doc "Update ghost-tvl-weight (W_i) on FVT|T|ScoreEntityLink."
        (require-capability (SECURE))
        (update FVT|T|ScoreEntityLink (UCk_ScoreEntityLink fvt-id score-entity-id) {"ghost-tvl-weight": ghost-tvl-weight})
    )
    (defun WU_ScoreEntityLink|TotalLaneWeight:string
        (fvt-id:string score-entity-id:string total-lane-weight:decimal)
        @doc "Update total-lane-weight (farm-triplet Level-1 divisor Σ w-user) on FVT|T|ScoreEntityLink."
        (require-capability (SECURE))
        (update FVT|T|ScoreEntityLink (UCk_ScoreEntityLink fvt-id score-entity-id) {"total-lane-weight": total-lane-weight})
    )
    (defun WU_ScoreEntityLink|Capture:string
        (fvt-id:string score-entity-id:string capture-units:decimal capture-weight:decimal oracle-ts:time)
        @doc "DSA: set an agency's capture fields (ideal capacity, uptime-adjusted actual, last-oracle timestamp) on FVT|T|ScoreEntityLink."
        (require-capability (SECURE))
        (update FVT|T|ScoreEntityLink (UCk_ScoreEntityLink fvt-id score-entity-id)
            {"capture-units": capture-units, "capture-weight": capture-weight, "oracle-ts": oracle-ts})
    )
    (defun WU_ScoreEntityLink|Delegation:string
        (fvt-id:string score-entity-id:string delegation:bool)
        @doc "DSA: flip a member to (or from) a delegation agency on FVT|T|ScoreEntityLink."
        (require-capability (SECURE))
        (update FVT|T|ScoreEntityLink (UCk_ScoreEntityLink fvt-id score-entity-id) {"delegation": delegation})
    )
    ;; FVT|T|MemberUserWeight  Key = <User-ID> | <FVT-ID> | <Score-Entity-ID>
    (defun WW_MemberUserWeight:string
        (user-id:string fvt-id:string score-entity-id:string contrib-weight:decimal)
        @doc "Upsert farm-triplet per-user Level-1 weight snapshot (w-user at last stake/unstake)."
        (require-capability (SECURE))
        (write FVT|T|MemberUserWeight (UCk_MemberUserWeight user-id fvt-id score-entity-id)
            {"contrib-weight"          : contrib-weight
            ,"user-id"                 : user-id
            ,"fvt-id"                  : fvt-id
            ,"score-entity-id"         : score-entity-id})
    )
    (defun WU_MemberVault|AvailableRewards:string
        (fvt-id:string score-entity-id:string dptf-id:string available-rewards:decimal)
        @doc "Set member mini-vault available-rewards (upsert; preserves unclaimed-count)."
        (require-capability (SECURE))
        (write FVT|T|MemberVault (UCk_RpsMember fvt-id score-entity-id dptf-id)
            {"available-rewards"       : available-rewards
            ,"unclaimed-count"         : (UR_FVT-MV|UnclaimedCount fvt-id score-entity-id dptf-id)
            ,"fvt-id"                  : fvt-id
            ,"score-entity-id"         : score-entity-id
            ,"dptf-id"                 : dptf-id})
    )
    (defun WU_MemberVault|UnclaimedCount:string
        (fvt-id:string score-entity-id:string dptf-id:string direction:bool)
        @doc "Increment (true) / decrement (false, floored at 0) the member mini-vault unclaimed-count (upsert)."
        (require-capability (SECURE))
        (let ((old-uc:integer (UR_FVT-MV|UnclaimedCount fvt-id score-entity-id dptf-id)))
            (write FVT|T|MemberVault (UCk_RpsMember fvt-id score-entity-id dptf-id)
                {"unclaimed-count"     : (if direction (+ old-uc 1) (if (> old-uc 0) (- old-uc 1) 0))
                ,"available-rewards"   : (UR_FVT-MV|AvailableRewards fvt-id score-entity-id dptf-id)
                ,"fvt-id"              : fvt-id
                ,"score-entity-id"     : score-entity-id
                ,"dptf-id"             : dptf-id})
        )
    )
    (defun WW_UserPresence:string (fvt-id:string ouronet-account:string is-present:bool)
        @doc "Upsert the user's presence flag for this FVT (SECURE). Add-only true on stake; recomputed false on \
            \ the unstake that drops the user's last position."
        (require-capability (SECURE))
        (write FVT|T|UserPresence (UCk_UserPresence fvt-id ouronet-account)
            {"is-present"  : is-present
            ,"fvt-id"      : fvt-id
            ,"ouronet-id"  : ouronet-account})
    )
    (defun WU_FvtForcedFixCount|Add:string (fvt-id:string dptf-id:string user-id:string n:integer)
        @doc "Add n forced-fixes to (fvt, reward lane, user) — called by the enforced inject when it un-stales the \
            \ user's scores. No-op when n≤0. Upsert (SECURE)."
        (require-capability (SECURE))
        (if (<= n 0)
            "no forced fixes to record"
            (write FVT|T|ForcedFixCount (UCk_ForcedFixCount fvt-id dptf-id user-id)
                {"count"    : (+ (UR_FVT-FFC|Count fvt-id dptf-id user-id) n)
                ,"fvt-id"   : fvt-id
                ,"dptf-id"  : dptf-id
                ,"user-id"  : user-id})
        )
    )
    (defun WU_FvtForcedFixCount|Zero:string (fvt-id:string dptf-id:string user-id:string)
        @doc "Zero the forced-fix count for (fvt, reward lane, user) after the penalty has been charged at collect (SECURE)."
        (require-capability (SECURE))
        (write FVT|T|ForcedFixCount (UCk_ForcedFixCount fvt-id dptf-id user-id)
            {"count"    : 0
            ,"fvt-id"   : fvt-id
            ,"dptf-id"  : dptf-id
            ,"user-id"  : user-id})
    )
    ;;
    (defun WI_MultipletFamily:string
        (multiplet-family-id:string row:object{FVT|MultipletFamily})
        @doc "Insert FVT|T|MultipletFamily full row (C_IssueMultipletFamily only)."
        (require-capability (SECURE))
        (insert FVT|T|MultipletFamily multiplet-family-id row)
    )
    ;;
    (defun WI_RpsGlobal:string
        (fvt-id:string dptf-id:string row:object{FVT|RPS|Global})
        @doc "Insert FVT|T|RPS|Global full row (C_AddRewardLink admission)."
        (require-capability (SECURE))
        (insert FVT|T|RPS|Global (UCk_RpsGlobal fvt-id dptf-id) row)
    )
    (defun WU_RpsGlobal|RewardEnabled:string
        (fvt-id:string dptf-id:string reward-enabled:bool)
        @doc "Update reward-enabled on FVT|T|RPS|Global."
        (require-capability (SECURE))
        (update FVT|T|RPS|Global (UCk_RpsGlobal fvt-id dptf-id) {"reward-enabled": reward-enabled})
    )
    (defun WU_RpsGlobal|CurrentRps:string
        (fvt-id:string dptf-id:string current-rps:decimal)
        @doc "Update current-rps (Tier-2 G) on FVT|T|RPS|Global."
        (require-capability (SECURE))
        (update FVT|T|RPS|Global (UCk_RpsGlobal fvt-id dptf-id) {"current-rps": current-rps})
    )
    (defun WU_RpsGlobal|AvailableRewards:string
        (fvt-id:string dptf-id:string available-rewards:decimal)
        @doc "Update available-rewards on FVT|T|RPS|Global."
        (require-capability (SECURE))
        (update FVT|T|RPS|Global (UCk_RpsGlobal fvt-id dptf-id) {"available-rewards": available-rewards})
    )
    (defun WU_RpsGlobal|UnclaimedCount:string
        (fvt-id:string dptf-id:string unclaimed-count:integer)
        @doc "Update unclaimed-count on FVT|T|RPS|Global."
        (require-capability (SECURE))
        (update FVT|T|RPS|Global (UCk_RpsGlobal fvt-id dptf-id) {"unclaimed-count": unclaimed-count})
    )
    (defun WU_RpsGlobal|ZombieRewards:string
        (fvt-id:string dptf-id:string zombie-rewards:decimal)
        @doc "Set zombie-rewards (escrow-on-empty limbo balance) on FVT|T|RPS|Global."
        (require-capability (SECURE))
        (update FVT|T|RPS|Global (UCk_RpsGlobal fvt-id dptf-id) {"zombie-rewards": zombie-rewards})
    )
    (defun WU_RpsGlobal|RoyaltyRewards:string
        (fvt-id:string dptf-id:string royalty-rewards:decimal)
        @doc "DSA: set royalty-rewards (the uptime-shortfall custody pool) on FVT|T|RPS|Global."
        (require-capability (SECURE))
        (update FVT|T|RPS|Global (UCk_RpsGlobal fvt-id dptf-id) {"royalty-rewards": royalty-rewards})
    )
    (defun WU_RpsGlobal|StreamCount:string
        (fvt-id:string dptf-id:string stream-count:integer)
        @doc "Set stream-count (live stream positions on this lane) on FVT|T|RPS|Global."
        (require-capability (SECURE))
        (update FVT|T|RPS|Global (UCk_RpsGlobal fvt-id dptf-id) {"stream-count": stream-count})
    )
    (defun WU_RpsGlobal|StreamLastRelease:string
        (fvt-id:string dptf-id:string stream-last-release:time)
        @doc "Set stream-last-release (shared lane drip checkpoint) on FVT|T|RPS|Global."
        (require-capability (SECURE))
        (update FVT|T|RPS|Global (UCk_RpsGlobal fvt-id dptf-id) {"stream-last-release": stream-last-release})
    )
    (defun WU_RpsGlobal|StreamUnreleased:string
        (fvt-id:string dptf-id:string stream-unreleased:decimal)
        @doc "Set stream-unreleased (custodied-but-not-yet-dripped total) on FVT|T|RPS|Global."
        (require-capability (SECURE))
        (update FVT|T|RPS|Global (UCk_RpsGlobal fvt-id dptf-id) {"stream-unreleased": stream-unreleased})
    )
    (defun WW_RpsStream:string
        (fvt-id:string dptf-id:string position:integer row:object{FVT|RPS|Stream})
        @doc "Upsert a FVT|T|RPS|Stream row (add-stream + drip compaction rewrite; overwrites a stale pruned slot)."
        (require-capability (SECURE))
        (write FVT|T|RPS|Stream (UCk_RpsStream fvt-id dptf-id position) row)
    )
    ;;
    (defun WI_RpsMember:string
        (fvt-id:string score-entity-id:string dptf-id:string row:object{FVT|RPS|Member})
        @doc "Insert FVT|T|RPS|Member full row (phase 2.1 ensure path)."
        (require-capability (SECURE))
        (insert FVT|T|RPS|Member (UCk_RpsMember fvt-id score-entity-id dptf-id) row)
    )
    (defun WW_RpsMember:string
        (fvt-id:string score-entity-id:string dptf-id:string row:object{FVT|RPS|Member})
        @doc "Upsert full FVT|T|RPS|Member row (Tier-2 settle paths)."
        (require-capability (SECURE))
        (write FVT|T|RPS|Member (UCk_RpsMember fvt-id score-entity-id dptf-id) row)
    )
    ;;
    (defun WI_RpsUser:string
        (user-id:string fvt-id:string score-entity-id:string dptf-id:string row:object{FVT|RPS|User})
        @doc "Insert FVT|T|RPS|User full row (phase 2.1 ensure path)."
        (require-capability (SECURE))
        (insert FVT|T|RPS|User (UCk_RpsUser user-id fvt-id score-entity-id dptf-id) row)
    )
    (defun WU_RpsUser|LastRps:string
        (user-id:string fvt-id:string score-entity-id:string dptf-id:string last-rps:decimal)
        @doc "Update last-rps on FVT|T|RPS|User."
        (require-capability (SECURE))
        (update FVT|T|RPS|User (UCk_RpsUser user-id fvt-id score-entity-id dptf-id) {"last-rps": last-rps})
    )
    (defun WU_RpsUser|PendingRewards:string
        (user-id:string fvt-id:string score-entity-id:string dptf-id:string pending-rewards:decimal)
        @doc "Update pending-rewards on FVT|T|RPS|User."
        (require-capability (SECURE))
        (update FVT|T|RPS|User (UCk_RpsUser user-id fvt-id score-entity-id dptf-id) {"pending-rewards": pending-rewards})
    )
    (defun WU_AgencyFee:string (fvt-id:string score-entity-id:string operator-konto:string fee-per-mille:integer)
        @doc "Write a delegation member's operator + fee mirror. require SECURE."
        (require-capability (SECURE))
        (write FVT|T|AgencyFee (UCk_ScoreEntityLink fvt-id score-entity-id)
            {"operator-konto" : operator-konto, "fee-per-mille" : fee-per-mille})
    )
    (defun WI_QualitySplit:string
        (fvt-id:string dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
        @doc "Write a reward's quality-split config (mode + 3-lane matrix). require SECURE."
        (require-capability (SECURE))
        (write FVT|T|QualitySplit (UCk_RpsGlobal fvt-id dptf-id)
            {"mode"         : mode
            ,"bronze-split" : bronze-split
            ,"silver-split" : silver-split
            ,"gold-split"   : gold-split
            ,"fvt-id"       : fvt-id
            ,"dptf-id"      : dptf-id})
    )
    ;;{5.6}  Aux/X
    ;; [XI]
    ;;
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
    ;;  FVT lazy-sync on reward entry (C_AddScoreEntity, C_Inject, XI_SettleStakePendingRewards phase-2 entry, CC_Collect):
    ;;  read SWP::UR_StoaValue via ScoreEntityLink.swpair; if W_live ≠ W_cached settle Tier-2 at old W_i; write W_i; fix S.
    ;;
    ;; --- Block L · Lifecycle XI (C_Issue / C_AddScoreEntity / …) ---
    ;;   C_Issue / C_RotateOwnership / C_Control / C_SetCommonDenominator
    ;;     └ XI_IssueFvt / XI_RotateOwnership / XI_Control / XI_SetCommonDenominator
    ;;   C_AddScoreEntity / C_ToggleScoreEntityLink
    ;;     └ XI_AddScoreEntity / XI_ToggleScoreEntityLink
    ;;   C_AddRewardLink / C_ToggleRewardLink
    ;;     └ XI_AddRewardLink / XI_ToggleRewardLink
    ;;   C_Inject — phased recipe (see canonical inject map above C_Inject)
    ;;   CC_Collect — phased recipe (see canonical collect map above CC_Collect)
    ;;
    (defun XI_IssueFvt:string
        (fvt-id:string fvt-class:integer owner-konto:string common-denominator:string)
        @doc "Under SECURE (FVT|C>ISSUE-FVT): insert FVT|T row with zeroed aggregates and enabled-reward-count 0."
        ;; SECURE: granted by WI_Fvt (underlying W_).
        (WI_Fvt fvt-id
            (UDC_FVT|Schema
                fvt-class owner-konto true true common-denominator
                0.0 0.0 0.0 0.0 0 0 0 true CT_MEMBERSHIP_MODE_BAR false
                ;; split-mode: farm (class 0) default participation; vault/treasury get the "|" sentinel (never read)
                (if (= fvt-class 0) CT_SPLIT_MODE_STAKED CT_SPLIT_MODE_NA) fvt-id
            )
        )
    )
    (defun XI_SetMosaic:string
        (fvt-id:string mosaic:bool)
        @doc "Under SECURE (FVT|C>SET-MOSAIC): update mosaic; reset membership-mode to BAR."
        (WU2_Fvt|MosaicPolicy fvt-id mosaic CT_MEMBERSHIP_MODE_BAR)
    )
    (defun XI_SetSplitMode:string
        (fvt-id:string split-mode:string)
        @doc "Under SECURE (FVT|C>SET-SPLIT-MODE): update the farm reward-split mode (SPLIT|STAKED | SPLIT|TVL)."
        (WU_Fvt|SplitMode fvt-id split-mode)
    )
    (defun XI_RotateOwnership:string
        (fvt-id:string new-owner-konto:string)
        @doc "Under SECURE (FVT|C>ROTATE-OWNERSHIP-FVT): update owner-konto only."
        ;; SECURE: granted by WU_Fvt|OwnerKonto (underlying W_).
        (WU_Fvt|OwnerKonto fvt-id new-owner-konto)
    )
    (defun XI_Control:string
        (fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Under SECURE (FVT|C>CONTROL-FVT): update can-upgrade and can-change-owner."
        ;; SECURE: granted by WU2_Fvt|Control (underlying W_).
        (WU2_Fvt|Control fvt-id new-can-upgrade new-can-change-owner)
        fvt-id
    )
    (defun XI_SetCommonDenominator:string
        (fvt-id:string common-denominator:string)
        @doc "Under SECURE (FVT|C>SET-COMMON-DENOMINATOR): update farm common-denominator."
        ;; SECURE: granted by WU_Fvt|CommonDenominator (underlying W_).
        (WU_Fvt|CommonDenominator fvt-id common-denominator)
    )
    (defun XI_AddScoreEntity:string
        (fvt-id:string score-entity-type:integer score-entity-id:string swpair:string ghost-weight:decimal)
        @doc "Under SECURE: insert enabled ScoreEntityLink; farm adds W_i to S; lock membership-mode when non-mosaic."
        (let ((ref-SCR:module{AcquisitionScoresV1} AQP-SCORE))
            (WI_ScoreEntityLink fvt-id score-entity-id
                (UDC_FVT|ScoreEntityLink score-entity-type true swpair ghost-weight 0.0 false 0.0 0.0 STREAM_EPOCH fvt-id score-entity-id)
            )
            (WU_Fvt|MemberLinkCount fvt-id (+ (UR_FVT|MemberLinkCount fvt-id) 1))
            (if (and (not (UR_FVT|Mosaic fvt-id)) (= (UR_FVT|MembershipMode fvt-id) CT_MEMBERSHIP_MODE_BAR))
                (WU_Fvt|MembershipMode fvt-id
                    (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                        (if (ref-SCR::UR_SCR|TripletTrueTriplet score-entity-id)
                            CT_MEMBERSHIP_MODE_TRUE_TRIPLET
                            CT_MEMBERSHIP_MODE_STANDARD_TRIPLET)
                        CT_MEMBERSHIP_MODE_SCORE))
                fvt-id)
            (if (= (UR_FVT|FvtClass fvt-id) 0)
                (WU_Fvt|TotalGhostTvlWeight fvt-id (+ (UR_FVT|TotalGhostTvlWeight fvt-id) ghost-weight))
                ;; M2/#11: vault/treasury — add the new member's LIVE deb-weight to the total-deb mirror
                ;; (0 for a fresh member; nonzero if its scores already carry deb).
                (WU_Fvt|TotalDebScore fvt-id
                    (+ (UR_FVT|TotalDebScore fvt-id)
                       (URC_ScoreEntityMemberDebWeight score-entity-type score-entity-id))))
        )
    )
    (defun XI_ToggleScoreEntityLink:string
        (fvt-id:string score-entity-id:string enabled:bool)
        @doc "Under SECURE (FVT|C>TOGGLE-SCORE-ENTITY-LINK): flip enabled; farm adjusts S by ±W_i on change."
        ;; SECURE: granted by WU_ScoreEntityLink|Enabled and WU_Fvt|TotalGhostTvlWeight (underlying W_).
        (let
            (
                (prev-enabled:bool (UR_FVT-SEL|Enabled fvt-id score-entity-id))
                (w:decimal (UR_FVT-SEL|GhostTvlWeight fvt-id score-entity-id))
                (fvt-class:integer (UR_FVT|FvtClass fvt-id))
                (changed:bool (!= enabled prev-enabled))
                (delta:decimal
                    (if (and (= fvt-class 0) changed)
                        (if enabled w (- 0.0 w))
                        0.0
                    )
                )
                ;; M2/#11: vault/treasury total-deb mirror ± the member's LIVE deb-weight on enable/disable
                (deb-delta:decimal
                    (if (and (!= fvt-class 0) changed)
                        (let
                            (
                                (d:decimal
                                    (URC_ScoreEntityMemberDebWeight
                                        (UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id) score-entity-id))
                            )
                            (if enabled d (- 0.0 d)))
                        0.0
                    )
                )
            )
            (WU_ScoreEntityLink|Enabled fvt-id score-entity-id enabled)
            (if (!= delta 0.0)
                (WU_Fvt|TotalGhostTvlWeight fvt-id (+ (UR_FVT|TotalGhostTvlWeight fvt-id) delta))
                fvt-id
            )
            (if (!= deb-delta 0.0)
                (WU_Fvt|TotalDebScore fvt-id (+ (UR_FVT|TotalDebScore fvt-id) deb-delta))
                fvt-id
            )
        )
    )
    (defun XI_IssueMultipletFamily:string
        (
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
        )
        @doc "Under SECURE (FVT|C>ISSUE-MULTIPLET-FAMILY): insert active MultipletFamily row."
        (let
            (
                (family-id:string (UCk_MultipletFamily token-0-id token-1-id token-2-id))
            )
            (WI_MultipletFamily family-id
                (UDC_FVT|MultipletFamily token-0-id token-1-id token-2-id ats-0-1-id ats-1-2-id 3 true family-id)
            )
            family-id
        )
    )
    (defun XI_AddRewardLink:string
        (fvt-id:string reward-dptf-id:string segmentation:bool reward-kind:string multiplet-family-id:string)
        @doc "Under SECURE (FVT|C>ADD-REWARD-LINK): insert reward-enabled RPS|Global; +1 enabled-reward-count."
        ;; SECURE: granted by WI_RpsGlobal and WU_Fvt|EnabledRewardCount (underlying W_).
        (WI_RpsGlobal fvt-id reward-dptf-id
            (UDC_FVT|RPS|Global true 0.0 0.0 0 0.0 segmentation reward-kind multiplet-family-id 0 STREAM_EPOCH 0.0 0.0 fvt-id reward-dptf-id)
        )
        (WU_Fvt|EnabledRewardCount fvt-id (+ (UR_FVT|EnabledRewardCount fvt-id) 1))
        fvt-id
    )
    (defun XI_ToggleRewardLink:string
        (fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Under SECURE (FVT|C>TOGGLE-REWARD-LINK): flip reward-enabled; ±1 enabled-reward-count on change."
        ;; SECURE: granted by WU_RpsGlobal|RewardEnabled and WU_Fvt|EnabledRewardCount (underlying W_).
        (let
            (
                (prev-enabled:bool (UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id))
                (count-delta:integer (if (= enabled prev-enabled) 0 (if enabled 1 -1)))
            )
            (WU_RpsGlobal|RewardEnabled fvt-id reward-dptf-id enabled)
            (if (!= count-delta 0)
                (WU_Fvt|EnabledRewardCount fvt-id (+ (UR_FVT|EnabledRewardCount fvt-id) count-delta))
                fvt-id
            )
        )
    )
    ;;
    ;; --- Block D · Inject (UrStoa C_URV|Inject / XI_URV|Inject analogue) ---
    ;;   C_Inject — phased recipe in C_ body (no monolithic XI_Inject)
    ;;     ├ XI_SyncFarmGhostTvlForInject (farm-only wrapper)
    ;;     ├ TFT::C_Transfer
    ;;     ├ WU_RpsGlobal|CurrentRps
    ;;     └ WU_RpsGlobal|AvailableRewards
    ;;
    ;; --- Block E · Collect (UrStoa C_URV|Collect analogue) ---
    ;;   CC_Collect — phased recipe in C_ body (same structure as C_Inject / CC_TrueFungibleStakeFlow)
    ;;     ├ XI_TransferRewardDptfFromVault            (coin 1 · URC_CollectClaimableRewards inside)
    ;;     ├ WU_RpsGlobal|AvailableRewards decrement (coin 5 · pre-reset URC read)
    ;;     ├ WU_RpsUser|PendingRewards reset           (coin 2)
    ;;     ├ XI_BookCollectUnclaimed                    (coin 3)
    ;;     └ WU_RpsUser|LastRps checkpoint             (coin 4)
    ;;
    (defun XI_SyncFarmGhostTvlForInject:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string)
        @doc "Tier 0 inject prelude: farm ghost-TVL lazy sync when needed."
        ;; SECURE: granted by XI_1|SyncFarmGhostTvlForEmployedScores (underlying W_).
        (if (= (UR_FVT|FvtClass fvt-id) 0)
            (XI_1|SyncFarmGhostTvlForEmployedScores (URHC_BuildInjectScorePlans fvt-id))
            (UC_EmptyOc)
        )
    )
    (defun XI_TransferRewardDptfFromVault:object{IgnisCollectorV1.OutputCumulator}
        (patron:string pool-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "PHASE 1.1 collect — plain TFT or MULTIPLET_BASE lane split (Coil/Curl via ATSU)."
        (require-capability (SECURE))
        (let
            (
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-ATSU:module{AutostakeUsageV1} ATSU)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (reward-kind:string (UR_FVT-RG|RewardKind fvt-id reward-dptf-id))
                (payout:decimal (URC_CollectClaimableRewards patron pool-id fvt-id score-entity-type score-entity-id reward-dptf-id))
            )
            (if (<= payout 0.0)
                (UC_EmptyOc)
                (if (and (= reward-kind CT_REWARD_KIND_MULTIPLET_BASE) (= score-entity-type CT_SCORE_ENTITY_TRIPLET))
                    (let
                        (
                            (mf-id:string (UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
                            (lanes:object (URC_ComputeTripletLanes patron pool-id score-entity-id))
                            (lane-b:decimal (at "lane-b" lanes))
                            (lane-s:decimal (at "lane-s" lanes))
                            (lane-g:decimal (at "lane-g" lanes))
                            (w-total:decimal (at "w-user" lanes))
                            (token-0:string (UR_FVT-MF|Token0Id mf-id))
                            (ats-01:string (UR_FVT-MF|Ats01Id mf-id))
                            (ats-12:string (UR_FVT-MF|Ats12Id mf-id))
                            (prec:integer (ref-DPTF::UR_Decimals token-0))
                            ;; Round B: HETEROGENEOUS ⇒ each lane splits across all 3 ladder tokens per the matrix
                            (mode:string (UR_FVT-QS|Mode fvt-id reward-dptf-id))
                            (amt-b:decimal (if (> w-total 0.0) (floor (* payout (/ lane-b w-total)) prec) 0.0))
                            (amt-s:decimal (if (> w-total 0.0) (floor (* payout (/ lane-s w-total)) prec) 0.0))
                            (amt-g:decimal (- payout (+ amt-b amt-s)))
                            (fund-sg:decimal (+ amt-s amt-g))
                            ;; #10 precision fallback: preview each lane's ATS conversion; when a tiny amount's
                            ;; pool-index result rounds below token precision to 0, SKIP the Coil/Curl — the patron
                            ;; keeps that portion as token-0 (already funded via fund-sg). No ATSU change; value preserved.
                            (coil-s-ok:bool
                                (if (> amt-s 0.0)
                                    (> (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 amt-s)) 0.0)
                                    false))
                            (curl-g-ok:bool
                                (if (> amt-g 0.0)
                                    (let ((h1:object (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 amt-g)))
                                        (if (> (at "rbt-amount" h1) 0.0)
                                            (> (at "rbt-amount"
                                                    (ref-ATS::URC_RewardBearingTokenAmounts ats-12 (at "rbt-id" h1) (at "rbt-amount" h1)))
                                               0.0)
                                            false))
                                    false))
                        )
                        (if (= mode CT_REWARD_MODE_HETEROGENEOUS)
                            ;; heterogeneous: each lane → all 3 ladder tokens per the FVT|QualitySplit matrix
                            (XI_1|HeterogeneousLaneRoute patron fvt-id reward-dptf-id mf-id amt-b amt-s amt-g prec)
                            ;; homogeneous (default): bronze → token-0 raw, silver → token-1 (coil), gold → token-2 (curl)
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [
                                    (if (> amt-b 0.0) (ref-TFT::C_Transfer token-0 AQP|SC_NAME patron amt-b true) (UC_EmptyOc))
                                    (if (> fund-sg 0.0) (ref-TFT::C_Transfer token-0 AQP|SC_NAME patron fund-sg true) (UC_EmptyOc))
                                    (if coil-s-ok (ref-ATSU::C_Coil patron ats-01 token-0 amt-s) (UC_EmptyOc))
                                    (if curl-g-ok (ref-ATSU::C_Curl patron ats-01 ats-12 token-0 amt-g) (UC_EmptyOc))
                                ]
                                []
                            )
                        )
                    )
                    (ref-TFT::C_Transfer reward-dptf-id AQP|SC_NAME patron payout true)
                )
            )
        )
    )
    (defun XI_BookCollectUnclaimed:object{IgnisCollectorV1.OutputCumulator}
        (patron:string pool-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Tier 0 collect unclaimed wrapper."
        ;; SECURE: granted by XI_1|BookCollectUnclaimed (underlying W_).
        (XI_1|BookCollectUnclaimed patron pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
    )
    (defun XI_1|BookCollectUnclaimed:object{IgnisCollectorV1.OutputCumulator}
        (patron:string pool-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "PHASE 3.1 collect — coin step 3 · XI_URV|UpdateUnclaimedCount false when user-supply=0; \
            \ FVT adapt: deb-score=0 on this score."
        ;; SECURE: granted by XI_2|BumpRpsGlobalUnclaimed (underlying W_).
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                ;;
                (deb:decimal (URC_ScoreEntityUserWeight patron fvt-id pool-id score-entity-type score-entity-id))
            )
            (if (= deb 0.0)
                (do
                    (XI_2|BumpRpsGlobalUnclaimed fvt-id reward-dptf-id false)
                    ;; #10 Tier-1: this user left the member's claimant set → decrement its mini-vault count
                    (WU_MemberVault|UnclaimedCount fvt-id score-entity-id reward-dptf-id false)
                )
                true
            )
        )
        (UC_EmptyOc)
    )
    ;;
    ;; --- Block A · Phase 4.5 FVT total-deb mirror (post-SCORE) ---
    (defun XI_SyncFvtTotalDebMirrors:object{IgnisCollectorV1.OutputCumulator}
        (pre-member-debs:[object{FVT|MemberPreDeb}])
        @doc "After SCORE phase 4 (M2/#11): INCREMENTALLY update each touched vault/treasury member's FVT \
            \ total-deb-score mirror by (new live deb-weight − pre-SCORE deb-weight). No `keys` scan — only the \
            \ members settled this tx are touched (bounded). Farm members are skipped (ghost-tvl / split-at-inject). \
            \ Sequential map accumulates correctly when several members share one FVT."
        ;; SECURE: granted by WU_Fvt|TotalDebScore (underlying W_).
        (map
            (lambda (m:object{FVT|MemberPreDeb})
                (let
                    (
                        (fvt-id:string (at "fvt-id" m))
                    )
                    (if (= (UR_FVT|FvtClass fvt-id) 0)
                        true
                        (let
                            (
                                (new-deb:decimal
                                    (URC_ScoreEntityMemberDebWeight (at "score-entity-type" m) (at "score-entity-id" m)))
                                (delta:decimal (- new-deb (at "pre-deb" m)))
                            )
                            (if (!= delta 0.0)
                                (WU_Fvt|TotalDebScore fvt-id (+ (UR_FVT|TotalDebScore fvt-id) delta))
                                true))
                    )
                )
            )
            pre-member-debs
        )
        (UC_EmptyOc)
    )
    (defun XI_SyncTripletLaneWeights:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string settle-plans:[object{FVT|SettleScorePlan}])
        @doc "Phase 4.6 — after SCORE: for each TRUE-triplet member (any FVT class) the staker touched, \
            \ re-snapshot the user's Level-1 weight (live w-user) and adjust ScoreEntityLink.total-lane-weight \
            \ by (new − old). Keeps the L_i divisor a point-read (no staker scan) and consistent with the banked \
            \ numerator. Mirrors the read-old-at-2.3 / write-after-SCORE ordering XI_SyncFvtTotalDebMirrors relies \
            \ on. Non-true-triplet and singular members are skipped (they use the maintained SCR total-deb)."
        ;; SECURE: granted by WU_ScoreEntityLink|TotalLaneWeight / WW_MemberUserWeight (underlying W_).
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
            )
            (map
                (lambda (plan:object{FVT|SettleScorePlan})
                    (let
                        (
                            (fvt-id:string (at "fvt-id" plan))
                            (score-entity-type:integer (at "score-entity-type" plan))
                            (score-entity-id:string (at "score-entity-id" plan))
                        )
                        (if (and (= score-entity-type CT_SCORE_ENTITY_TRIPLET) (ref-SCR::UR_SCR|TripletTrueTriplet score-entity-id))
                            ;; silver-id's own AQP pool is the lane basis (matches the retired scan), independent
                            ;; of whichever leg triggered this settle.
                            (let
                                (
                                    (silver-pool:string
                                        (ref-SCR::UR_SCR|ScoreAqpoolLink (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id)))
                                )
                                (let
                                    (
                                        (new-cw:decimal
                                            (floor (URC_TripletUserLaneWeightLive beneficiary-id silver-pool score-entity-id) CT_FVT_RPS_PREC))
                                        (old-cw:decimal (UR_FVT-MUW|ContribWeight beneficiary-id fvt-id score-entity-id))
                                    )
                                    (do
                                        (WU_ScoreEntityLink|TotalLaneWeight fvt-id score-entity-id
                                            (+ (UR_FVT-SEL|TotalLaneWeight fvt-id score-entity-id) (- new-cw old-cw)))
                                        (WW_MemberUserWeight beneficiary-id fvt-id score-entity-id new-cw)
                                    )
                                )
                            )
                            true
                        )
                    )
                )
                settle-plans
            )
        )
        (UC_EmptyOc)
    )
    ;; --- Block A · Phase 4.7 FVT user-presence ADD (M3 #12 / H4 sweep enumeration) ---
    (defun XI_MarkFvtPresence:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string distinct-fvts:[string])
        @doc "Phase 4.7 — mark the staker present in every FVT this stake touched (add-only, idempotent `true`). \
            \ `distinct-fvts` is already computed by the settle bundle, so this is a bounded set of point-writes, \
            \ no scan. Over-marking is harmless: the sweep no-ops on a zero-weight user, and the unstake path \
            \ recomputes `false` when the user's last position in an FVT is dropped."
        ;; SECURE: granted by WW_UserPresence (underlying W_).
        (map (lambda (fvt-id:string) (WW_UserPresence fvt-id beneficiary-id true)) distinct-fvts)
        (UC_EmptyOc)
    )
    (defun XI_RecomputeFvtPresence:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string distinct-fvts:[string])
        @doc "Phase 4.7 (UNSTAKE side) — for each FVT this unstake touched, recompute the user's membership across \
            \ ALL of that FVT's score-entities (URC_FvtUserStillPresent) and write the result. Flips is-present → \
            \ false exactly when this unstake dropped the user's LAST position in the FVT; stays true if the user \
            \ is still in via another pool/score. HEAVY (a member enumeration per touched FVT), but unstake is a \
            \ user-paced path and the presence table is the price of a scan-free sweep. Runs after phase 4/4.6."
        ;; SECURE: granted by WW_UserPresence (underlying W_).
        (map
            (lambda (fvt-id:string)
                (WW_UserPresence fvt-id beneficiary-id (URC_FvtUserStillPresent fvt-id beneficiary-id)))
            distinct-fvts
        )
        (UC_EmptyOc)
    )
    (defun XI_SyncFvtPresence:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string distinct-fvts:[string] direction:bool)
        @doc "Phase 4.7 dispatcher: STAKE (direction=true) → add-only mark present; UNSTAKE (false) → recompute \
            \ membership and flip to false when the last position is gone. Keeps the stake path a cheap point-write \
            \ while making the boolean truthful on withdrawal."
        (if direction
            (XI_MarkFvtPresence beneficiary-id distinct-fvts)
            (XI_RecomputeFvtPresence beneficiary-id distinct-fvts)
        )
    )
    ;;
    ;; --- Block A · Phase 2.1 settle (CC_TrueFungibleStakeFlow) ---
    ;;   XI_RpsPreScore — orchestrator: ghost TVL → ensure rows → bank pending
    ;;     └ (map) → XI_1|EnsureScoreRewardRows, XI_1|BankScorePendingRewards
    ;;
    (defun XI_RpsPreScore:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object{FVT|StakeSettleBundle})
        @doc "RPS prelude orchestrator — ghost TVL sync, ensure rows, bank pending at OLD deb (UrStoa UpdatePendingRewards block)."
        ;; SECURE: granted by XI_1|SyncFarmGhostTvlForEmployedScores / XI_1|EnsureScoreRewardRows / XI_1|BankScorePendingRewards (underlying W_).
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                (settle-scores:[string] (at "settle-scores" settle-bundle))
                (distinct-fvts:[string] (at "distinct-fvts" settle-bundle))
                (settle-plans:[object{FVT|SettleScorePlan}] (at "settle-plans" settle-bundle))
            )
            ;; PHASE 2.0 — DRIP every affected reward lane FIRST (checkpoint) so the ghost-TVL / Tier-2 settle and
            ;; the per-user banking below run against the now-current index (streamed rewards vest up to `now`).
            ;; Uses the plans' own reward-dptf-ids (no extra scan); a lane shared by two plans is dripped twice —
            ;; the 2nd drip is a no-op (elapsed 0). No-op entirely when no lane on the plan carries a live stream.
            (map
                (lambda (plan:object{FVT|SettleScorePlan})
                    (map (lambda (reward-dptf-id:string) (XI_ReleaseStream (at "fvt-id" plan) reward-dptf-id))
                         (at "reward-dptf-ids" plan)))
                settle-plans)
            (XI_1|SyncFarmGhostTvlForEmployedScores settle-plans)
            (map
                (lambda (plan:object{FVT|SettleScorePlan})
                    (do
                        (XI_1|EnsureScoreRewardRows beneficiary-id plan)
                        (XI_1|BankScorePendingRewards beneficiary-id pool-id plan)
                    )
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
    (defun XI_1|EnsureScoreRewardRows
        (beneficiary-id:string plan:object{FVT|SettleScorePlan})
        @doc "Phase 2.2 — UrStoa ≡ insert UrStoaVaultUser when account absent (IzAccount false)."
        ;; SECURE: granted by XI_2|EnsureRpsMemberRow / XI_2|EnsureRpsUserRow (underlying W_).
        (let
            (
                (fvt-id:string (at "fvt-id" plan))
                (score-entity-type:integer (at "score-entity-type" plan))
                (score-entity-id:string (at "score-entity-id" plan))
                (reward-dptf-ids:[string] (at "reward-dptf-ids" plan))
            )
            (map
                (lambda (reward-dptf-id:string)
                    (if (UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id)
                        (do
                            (XI_2|EnsureRpsMemberRow fvt-id score-entity-id reward-dptf-id)
                            (XI_2|EnsureRpsUserRow beneficiary-id fvt-id score-entity-id reward-dptf-id)
                        )
                        true
                    )
                )
                reward-dptf-ids
            )
        )
    )
    (defun XI_1|BankScorePendingRewards
        (beneficiary-id:string pool-id:string plan:object{FVT|SettleScorePlan})
        @doc "Phase 2.3 — UrStoa ≡ XI_URV|UpdatePendingRewards (bank at OLD deb × ΔL_i)."
        ;; SECURE: granted by XI_2|SettleMemberTier2 / XI_2|BankUserTier1Pending (underlying W_).
        (let
            (
                (score-entity-type:integer (at "score-entity-type" plan))
                (score-entity-id:string (at "score-entity-id" plan))
                (fvt-id:string (at "fvt-id" plan))
                (reward-dptf-ids:[string] (at "reward-dptf-ids" plan))
            )
            (map
                (lambda (reward-dptf-id:string)
                    (if (UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id)
                        (do
                            (XI_2|SettleMemberTier2 fvt-id score-entity-type score-entity-id reward-dptf-id)
                            (XI_2|BankUserTier1Pending beneficiary-id pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
                        )
                        true
                    )
                )
                reward-dptf-ids
            )
        )
    )
    (defun XI_1|SyncFarmGhostTvlForEmployedScores:object{IgnisCollectorV1.OutputCumulator}
        (score-plans:[object{FVT|SettleScorePlan}])
        @doc "Core ghost-TVL sync (phase 2.1 / inject / collect): SWP→FVT reconcile per object{FVT|SettleScorePlan}. \
            \ Caller builds plans once with reward-dptf-ids from a single URH_FVT|SettleFvtRewardBundle — no URD in child XI. \
            \ Per row: read SWP::UR_StoaValue via swpair; if W_live ≠ W_cached settle Tier-2 at old W_i, \
            \ write ghost-tvl-weight, adjust FVT|T.total-ghost-tvl-weight. \
            \ Stake/unstake (XI_RpsPreScore) and tier-0 inject/collect wrappers call this."
        ;; SECURE: granted by XI_2|SettleMemberTier2, WU_ScoreEntityLink|GhostTvlWeight, WU_Fvt|TotalGhostTvlWeight (underlying W_).
        (let
            (
                (ref-SWP:module{SwapperV3} SWP)
            )
            ;; map: employed score plans (farm ghost-TVL reconcile per score × FVT link)
            (map
                (lambda (plan:object{FVT|SettleScorePlan})
                    (let
                        (
                            (score-entity-type:integer (at "score-entity-type" plan))
                (score-entity-id:string (at "score-entity-id" plan))
                            (fvt-id:string (at "fvt-id" plan))
                            (reward-dptf-ids:[string] (at "reward-dptf-ids" plan))
                        )
                        (if
                            (fold (and) true
                                [
                                    (!= score-entity-id BAR)
                                    (!= fvt-id BAR)
                                    (= (UR_FVT|FvtClass fvt-id) 0)
                                    (UR_FVT-SEL|Enabled fvt-id score-entity-id)
                                    ;; DSA delegation members ride the class-0 farm code but have no LP swpair ("|",
                                    ;; ghost 0) — their inject weight is CAPTURE, not ghost-TVL. Skip the SWP sync.
                                    (not (UR_FVT-SEL|Delegation fvt-id score-entity-id))
                                ]
                            )
                            (let
                                (
                                    (swpair:string (UR_FVT-SEL|Swpair fvt-id score-entity-id))
                                    (W-live:decimal (ref-SWP::UR_StoaValue swpair))
                                    (W-cached:decimal (UR_FVT-SEL|GhostTvlWeight fvt-id score-entity-id))
                                )
                                (if (= W-live W-cached)
                                    true
                                    (let
                                        (
                                            (delta-W:decimal (- W-live W-cached))
                                            (S:decimal (UR_FVT|TotalGhostTvlWeight fvt-id))
                                        )
                                        (map
                                            (lambda (reward-dptf-id:string)
                                                (XI_2|SettleMemberTier2 fvt-id score-entity-type score-entity-id reward-dptf-id)
                                            )
                                            reward-dptf-ids
                                        )
                                        (WU_ScoreEntityLink|GhostTvlWeight fvt-id score-entity-id W-live)
                                        (WU_Fvt|TotalGhostTvlWeight fvt-id (+ S delta-W))
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
        )
        (UC_EmptyOc)
    )
    (defun XI_2|EnsureRpsMemberRow
        (fvt-id:string score-entity-id:string reward-dptf-id:string)
        @doc "Internal (phase 2.1 · depth 2 · 2.0]): ensure FVT|T|RPS|Member row for (fvt, score, reward DPTF); insert when absent."
        ;; SECURE: granted by WI_RpsMember (underlying W_).
        (if (not (URC_FvtRpsMemberRowExists fvt-id score-entity-id reward-dptf-id))
            (WI_RpsMember fvt-id score-entity-id reward-dptf-id
                (UDC_FVT|RPS|Member 0.0 0.0 0.0 fvt-id score-entity-id reward-dptf-id)
            )
            true
        )
    )
    (defun XI_2|EnsureRpsUserRow
        (beneficiary-id:string fvt-id:string score-entity-id:string reward-dptf-id:string)
        @doc "Internal (phase 2.1 · depth 2 · 2.0]): ensure FVT|T|RPS|User row; insert with last-rps=L_i when absent (UrStoa IzAccount)."
        ;; SECURE: granted by WI_RpsUser (underlying W_).
        (if (not (URC_FvtRpsUserRowExists beneficiary-id fvt-id score-entity-id reward-dptf-id))
            (WI_RpsUser beneficiary-id fvt-id score-entity-id reward-dptf-id
                (UDC_FVT|RPS|User
                    (URC_FvtTier1IndexRps fvt-id score-entity-id reward-dptf-id)
                    0.0
                    beneficiary-id
                    fvt-id
                    score-entity-id
                    reward-dptf-id
                )
            )
            true
        )
    )
    (defun XI_1|FarmSplitInject:decimal
        (fvt-id:string reward-dptf-id:string amount:decimal S:decimal)
        @doc "Split-at-inject (audit LP redesign / Stage 2): distribute <amount> across enabled FARM members by \
            \ their FRESH staked STOA value (member-slice = amount x W_i / S), advancing each member's Tier-1 \
            \ index L_i (member-deb-rps) by member-slice / total-deb — or parking in pending-member-rewards when \
            \ the member has value but no stakers (total-deb = 0). No global G: farms distribute at inject, not \
            \ via a Tier-2 accumulator. Mirrors XI_2|SettleMemberTier2's row math with member-slice in place of earned. \
            \ DSA: a delegation member's W_i is its EFFECTIVE capture (uptime-adjusted, 0 if expired), while S sums \
            \ IDEAL capacity (capture-units); the per-member gap floor(amount×(ideal−W_i)/S) is the uptime shortfall, \
            \ accumulated and RETURNED so the caller routes it to the royalty pool (0 for every normal member, whose \
            \ ideal == W_i)."
        ;; SECURE: granted by WI_RpsMember / WW_RpsMember (underlying W_).
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (member-ids:[string] (URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
                (reward-prec:integer (ref-DPTF::UR_Decimals reward-dptf-id))
            )
            (fold
                (lambda (royalty-acc:decimal score-entity-id:string)
                    (do
                        (if (not (URC_FvtRpsMemberRowExists fvt-id score-entity-id reward-dptf-id))
                            (WI_RpsMember fvt-id score-entity-id reward-dptf-id
                                (UDC_FVT|RPS|Member 0.0 0.0 0.0 fvt-id score-entity-id reward-dptf-id)
                            )
                            true
                        )
                        (let
                            (
                                (score-entity-type:integer (UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id))
                                (swpair:string (UR_FVT-SEL|Swpair fvt-id score-entity-id))
                                (delegation:bool (UR_FVT-SEL|Delegation fvt-id score-entity-id))
                                ;; W_i (numerator): delegation ⇒ effective capture (uptime-adjusted, 0 if expired); else staked value
                                (w-i:decimal
                                    (if delegation
                                        (URC_MemberEffectiveCapture fvt-id score-entity-id)
                                        (URC_MemberLevel2Weight fvt-id score-entity-type score-entity-id swpair)))
                                ;; ideal capacity: delegation ⇒ capture-units; else == W_i (so its gap is 0)
                                (ideal-i:decimal
                                    (if delegation (UR_FVT-SEL|CaptureUnits fvt-id score-entity-id) w-i))
                                (member-slice:decimal (floor (/ (* amount w-i) S) reward-prec))
                                ;; uptime shortfall for this member (0 for a normal member; ideal-i == w-i)
                                (royalty-i:decimal (floor (/ (* amount (- ideal-i w-i)) S) reward-prec))
                                (total-deb:decimal (URC_ScoreEntityMemberTier2Divisor fvt-id score-entity-type score-entity-id))
                                ;; DSA operator fee: split the member-slice — the member index L_i advances by the
                                ;; NET (1−fee) so EVERY staker accrues net, and the whole fee slice is credited
                                ;; DIRECT to the operator's pending ⇒ operator earns own-share + fee (effective
                                ;; own + fee·Σdelegators), delegators (1−fee), conserved. Only when a delegation
                                ;; member has an operator fee AND live stakers (total-deb>0). Fee never touches a
                                ;; stored weight, so a fee change reprices only the NEXT inject (O(1)).
                                (operator:string (if delegation (UR_FVT-AF|Operator fvt-id score-entity-id) BAR))
                                (fee-per-mille:integer
                                    (if (fold (and) true [delegation (!= operator BAR) (> total-deb 0.0)])
                                        (UR_FVT-AF|FeePerMille fvt-id score-entity-id)
                                        0))
                                (member-slice-fee:decimal
                                    (if (> fee-per-mille 0)
                                        (floor (/ (* member-slice (dec fee-per-mille)) 1000.0) reward-prec)
                                        0.0))
                                (member-slice-net:decimal (- member-slice member-slice-fee))
                                (g-i:decimal (UR_FVT-RM|LastFarmRpsG fvt-id score-entity-id reward-dptf-id))
                                (L-i:decimal (UR_FVT-RM|MemberDebRps fvt-id score-entity-id reward-dptf-id))
                                (ptr:decimal (UR_FVT-RM|PendingMemberRewards fvt-id score-entity-id reward-dptf-id))
                                (L-i-work:decimal
                                    (if (and (> total-deb 0.0) (> ptr 0.0))
                                        (+ L-i (floor (/ ptr total-deb) CT_FVT_RPS_PREC))
                                        L-i
                                    )
                                )
                                (ptr-work:decimal
                                    (if (and (> total-deb 0.0) (> ptr 0.0)) 0.0 ptr)
                                )
                                (new-li:decimal
                                    (if (> total-deb 0.0)
                                        (+ L-i-work (floor (/ member-slice-net total-deb) CT_FVT_RPS_PREC))
                                        L-i-work
                                    )
                                )
                                (new-ptr:decimal
                                    (if (and (= total-deb 0.0) (> member-slice-net 0.0))
                                        (floor (+ ptr-work member-slice-net) reward-prec)
                                        ptr-work
                                    )
                                )
                            )
                            (WW_RpsMember fvt-id score-entity-id reward-dptf-id
                                (UDC_FVT|RPS|Member g-i new-li new-ptr fvt-id score-entity-id reward-dptf-id)
                            )
                            ;; #10 credit: this member's routed slice enters its mini-vault (Tier-1 dust sweep).
                            ;; The FULL slice enters (net rides L_i, fee rides operator pending) so paid == routed.
                            (WU_MemberVault|AvailableRewards fvt-id score-entity-id reward-dptf-id
                                (+ (UR_FVT-MV|AvailableRewards fvt-id score-entity-id reward-dptf-id) member-slice)
                            )
                            ;; DSA operator fee: credit the whole fee slice DIRECT to the operator's pending
                            ;; (survives deb refresh — pending is a free additive term, never scaled by weight).
                            (if (> member-slice-fee 0.0)
                                (do
                                    (XI_2|EnsureRpsUserRow operator fvt-id score-entity-id reward-dptf-id)
                                    (WU_RpsUser|PendingRewards operator fvt-id score-entity-id reward-dptf-id
                                        (+ (UR_FVT-RU|PendingRewards operator fvt-id score-entity-id reward-dptf-id) member-slice-fee))
                                )
                                true
                            )
                            ;; thread the uptime-shortfall accumulator (royalty-i is 0 for a normal member)
                            (+ royalty-acc royalty-i)
                        )
                    )
                )
                0.0
                member-ids
            )
        )
    )
    (defun XI_2|SettleMemberTier2:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Internal (phase 2.1 · depth 2 · 2a]): Tier-2 settle per reward DPTF on FVT|T|RPS|Member. \
            \ Farm: floor(W_i×(G−g_i), 48). Vault/Treasury: floor(D_i×(G−g_i), 48). Flush pending-member-rewards when deb > 0."
        ;; SECURE: granted by WI_RpsMember / WW_RpsMember (underlying W_).
        (do
            (if (not (URC_FvtRpsMemberRowExists fvt-id score-entity-id reward-dptf-id))
                (WI_RpsMember fvt-id score-entity-id reward-dptf-id
                    (UDC_FVT|RPS|Member 0.0 0.0 0.0 fvt-id score-entity-id reward-dptf-id)
                )
                true
            )
            (let
                (
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    ;;
                    (fvt-class:integer (UR_FVT|FvtClass fvt-id))
                    (G:decimal (UR_FVT-RG|CurrentRps fvt-id reward-dptf-id))
                    (g-i:decimal (UR_FVT-RM|LastFarmRpsG fvt-id score-entity-id reward-dptf-id))
                    (total-deb:decimal (URC_ScoreEntityMemberTier2Divisor fvt-id score-entity-type score-entity-id))
                    (L-i:decimal (UR_FVT-RM|MemberDebRps fvt-id score-entity-id reward-dptf-id))
                    (ptr:decimal (UR_FVT-RM|PendingMemberRewards fvt-id score-entity-id reward-dptf-id))
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
                )
                (if (= G g-i)
                    (if (and (> total-deb 0.0) (> ptr 0.0))
                        (WW_RpsMember fvt-id score-entity-id reward-dptf-id
                            (UDC_FVT|RPS|Member g-i L-i-work ptr-work fvt-id score-entity-id reward-dptf-id)
                        )
                        true
                    )
                    (let
                        (
                            (weight:decimal (URC_ScoreEntityMemberWeight fvt-id score-entity-type score-entity-id))
                            (earned:decimal (floor (* weight (- G g-i)) CT_FVT_RPS_PREC))
                            (new-li:decimal
                                (if (> total-deb 0.0)
                                    (+ L-i-work (floor (/ earned total-deb) CT_FVT_RPS_PREC))
                                    L-i-work
                                )
                            )
                            (new-ptr:decimal
                                (if (and (= total-deb 0.0) (> earned 0.0))
                                    (floor (+ ptr-work earned) reward-prec)
                                    ptr-work
                                )
                            )
                        )
                        (WW_RpsMember fvt-id score-entity-id reward-dptf-id
                            (UDC_FVT|RPS|Member G new-li new-ptr fvt-id score-entity-id reward-dptf-id)
                        )
                        ;; #10 credit: vault Tier-2 earned enters this member's mini-vault (Tier-1 dust sweep)
                        (WU_MemberVault|AvailableRewards fvt-id score-entity-id reward-dptf-id
                            (+ (UR_FVT-MV|AvailableRewards fvt-id score-entity-id reward-dptf-id) earned)
                        )
                    )
                )
            )
            (UC_EmptyOc)
        )
    )
    (defun XI_2|BankUserTier1Pending:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Internal (phase 2.1 · depth 2 · 2b]): bank user pending at OLD deb — UrStoa XI_URV|UpdatePendingRewards. \
            \ Does not advance last-rps (phase 2.4 XI_CheckpointStakeRps)."
        ;; SECURE: granted by WU_RpsUser|PendingRewards (underlying W_).
        (do
            (let
                (
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    ;;
                    (deb-old:decimal (URC_ScoreEntityUserWeight beneficiary-id fvt-id pool-id score-entity-type score-entity-id))
                    (new-pending:decimal (URC_UserTier1AvailableRewards beneficiary-id fvt-id score-entity-id reward-dptf-id deb-old))
                )
                (WU_RpsUser|PendingRewards beneficiary-id fvt-id score-entity-id reward-dptf-id new-pending)
            )
            (UC_EmptyOc)
        )
    )
    ;; --- Shared deb-staleness FIX (M3 #12 — used by CC_Inject AND collect PHASE 6 backstop) ---
    (defun XI_FixUserMemberDeb:object{IgnisCollectorV1.OutputCumulator}
        (user-id:string fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "Single-member convenience: scans the FVT's reward rows once, then delegates to XI_FixUserMemberDebIn."
        (require-capability (SECURE))
        (XI_FixUserMemberDebIn user-id fvt-id score-entity-type score-entity-id (URH_FVT-RG|EnabledRewardRows fvt-id))
    )
    (defun XI_FixUserMemberDebIn:object{IgnisCollectorV1.OutputCumulator}
        (user-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-rows:[string])
        @doc "FIX one (user, member) settling over PRE-COMPUTED `reward-rows` (the FVT's enabled reward-dptf ids — \
            \ batch-invariant), so a chunk fix scans FVT|T|RPS|Global ONCE, not per (user × member). \
            \ Iff the member is deb-based (singular or NON-true triplet) AND stale for this \
            \ user — (1) SETTLE the user's pending at the OLD deb across ALL of the FVT's enabled reward-dptfs and \
            \ advance each last-rps to its current index (settle-before-weight-change MUST cover every stream, \
            \ because the deb-score is shared across streams); (2) refresh the SCORE deb-score(s) to the live \
            \ Elite-DEB (each triplet leg at its OWN aqpool-link); (3) resync the FVT total-deb mirror by the \
            \ member delta. No-op when fresh or a TRUE triplet (deb-independent lanes). Does NOT pay out. \
            \ NOTE: assumes the user's RPS|User rows exist for every enabled reward-dptf (ensured at stake); a \
            \ reward-dptf enabled AFTER the user staked is a known edge (ensure-rows-first) — TODO."
        (require-capability (SECURE))
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (triplet:bool (= score-entity-type CT_SCORE_ENTITY_TRIPLET))
                (bronze-id:string (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET) (ref-SCR::UR_SCR|TripletBronzeScoreId score-entity-id) score-entity-id))
                (silver-id:string (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET) (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id) score-entity-id))
                (golden-id:string (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET) (ref-SCR::UR_SCR|TripletGoldenScoreId score-entity-id) score-entity-id))
                ;; settle basis pool: singular -> its own; triplet -> silver leg (URC_ weight ignores pool for triplets)
                (member-pool:string (ref-SCR::UR_SCR|ScoreAqpoolLink silver-id))
            )
            (if (URC_FvtMemberDebNeedsFix fvt-id user-id score-entity-type score-entity-id)
                (let
                    (
                        (pre-member-debs:[object{FVT|MemberPreDeb}]
                            [ {"fvt-id"            : fvt-id
                              ,"score-entity-type" : score-entity-type
                              ,"score-entity-id"   : score-entity-id
                              ,"pre-deb"           : (URC_ScoreEntityMemberDebWeight score-entity-type score-entity-id)} ])
                    )
                    ;; 1. settle EVERY reward stream at OLD deb, then advance its last-rps to the current index
                    (map
                        (lambda (rdptf:string)
                            (do
                                (XI_2|BankUserTier1Pending user-id member-pool fvt-id score-entity-type score-entity-id rdptf)
                                (WU_RpsUser|LastRps user-id fvt-id score-entity-id rdptf
                                    (URC_FvtTier1IndexRps fvt-id score-entity-id rdptf))))
                        reward-rows)
                    ;; 2. refresh the SCORE deb-score(s) to live (each triplet leg at its OWN pool)
                    (if triplet
                        (map
                            (lambda (sid:string) (ref-SCR::XE_RefreshUserScoreDeb user-id (ref-SCR::UR_SCR|ScoreAqpoolLink sid) sid))
                            [ bronze-id silver-id golden-id ])
                        (ref-SCR::XE_RefreshUserScoreDeb user-id member-pool score-entity-id))
                    ;; 3. resync the FVT total-deb mirror by the member delta
                    (XI_SyncFvtTotalDebMirrors pre-member-debs)
                )
                (UC_EmptyOc)
            )
        )
    )
    (defun XI_SweepRecomputeUserMember:object{IgnisCollectorV1.OutputCumulator}
        (user-id:string fvt-id:string score-entity-type:integer score-entity-id:string swept-boost-class-id:string)
        @doc "Single-holder convenience: scans the FVT's reward rows once, then delegates to XI_SweepRecomputeUserMemberIn."
        (require-capability (SECURE))
        (XI_SweepRecomputeUserMemberIn user-id fvt-id score-entity-type score-entity-id swept-boost-class-id (URH_FVT-RG|EnabledRewardRows fvt-id))
    )
    (defun XI_SweepRecomputeUserMemberIn:object{IgnisCollectorV1.OutputCumulator}
        (user-id:string fvt-id:string score-entity-type:integer score-entity-id:string swept-boost-class-id:string reward-rows:[string])
        @doc "Re-score sweep per-holder recompute settling over PRE-COMPUTED `reward-rows` (batch-invariant) — a \
            \ sweep chunk scans FVT|T|RPS|Global once, not per holder. \
            \ [orig] for one (user, member) after an anchor in `swept-boost-class-id` \
            \ was removed/re-priced GLOBALLY. Order matters: (1) SETTLE every reward stream at the OLD weight + \
            \ advance last-rps (banks pending before any weight change); then dispatch — TRUE triplet (deb- \
            \ independent) → (2t) refold the Level-1 lanes at the live promile; deb-based (singular / non-true \
            \ triplet) → (2) REFOLD the holder's aggregate-promile for the swept class (ANK — the DEEPER recompute \
            \ XI_FixUserMemberDeb omits, since a DEF change makes the stored aggregate stale), (3) refresh the SCORE \
            \ deb-score(s) at the new aggregate, (4) resync the FVT total-deb mirror. Reuses the SAME leaf primitives \
            \ as the deb-fix, re-ordered to insert the aggregate refold. NO 2e penalty (owner-initiated, D4). \
            \ require SECURE."
        (require-capability (SECURE))
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                (triplet:bool (= score-entity-type CT_SCORE_ENTITY_TRIPLET))
                (triplet-true:bool (and (= score-entity-type CT_SCORE_ENTITY_TRIPLET) (ref-SCR::UR_SCR|TripletTrueTriplet score-entity-id)))
                (silver-id:string (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET) (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id) score-entity-id))
                ;; settle basis pool: singular → its own; triplet → silver leg (URC_ weight ignores pool for triplets)
                (member-pool:string (ref-SCR::UR_SCR|ScoreAqpoolLink silver-id))
            )
            ;; 1. settle EVERY reward stream at OLD weight, then advance its last-rps to the current index
            (map
                (lambda (rdptf:string)
                    (do
                        (XI_2|BankUserTier1Pending user-id member-pool fvt-id score-entity-type score-entity-id rdptf)
                        (WU_RpsUser|LastRps user-id fvt-id score-entity-id rdptf
                            (URC_FvtTier1IndexRps fvt-id score-entity-id rdptf))))
                reward-rows)
            ;; 2. refold the holder's aggregate-promile for the swept class — BOTH paths need it: the deb path picks
            ;;    it up via the score deb-recompute, AND the TRUE-triplet lanes read UR_UB|AggregatePromile directly
            ;;    (URC_ComputeTripletLanes). The DEEPER recompute the deb-fix omits — must precede the dispatch.
            (ref-ANK::XE_RecomputeUserBoostAggregates user-id [swept-boost-class-id])
            (if triplet-true
                ;; TRUE triplet (deb-independent): refold the Level-1 lanes — they read the now-fresh aggregate
                (XI_SyncTripletLaneWeights user-id
                    [(UDC_FVT|SettleScorePlan score-entity-type score-entity-id fvt-id [])])
                ;; deb-based (singular / NON-true triplet): refresh deb at the new aggregate → resync mirror
                (let
                    (
                        (pre-member-debs:[object{FVT|MemberPreDeb}]
                            [ {"fvt-id"            : fvt-id
                              ,"score-entity-type" : score-entity-type
                              ,"score-entity-id"   : score-entity-id
                              ,"pre-deb"           : (URC_ScoreEntityMemberDebWeight score-entity-type score-entity-id)} ])
                    )
                    ;; 3. refresh the SCORE deb-score(s) at the new aggregate (triplet legs at their OWN pools)
                    (if triplet
                        (map
                            (lambda (sid:string) (ref-SCR::XE_RefreshUserScoreDeb user-id (ref-SCR::UR_SCR|ScoreAqpoolLink sid) sid))
                            [ (ref-SCR::UR_SCR|TripletBronzeScoreId score-entity-id) silver-id (ref-SCR::UR_SCR|TripletGoldenScoreId score-entity-id) ])
                        (ref-SCR::XE_RefreshUserScoreDeb user-id member-pool score-entity-id))
                    ;; 4. resync the FVT total-deb mirror by the member delta
                    (XI_SyncFvtTotalDebMirrors pre-member-debs)
                )
            )
            (UC_EmptyOc)
        )
    )
    (defun XI_FixUserFvtDebIn:object{IgnisCollectorV1.OutputCumulator}
        (user-id:string fvt-id:string members:[string] reward-rows:[string])
        @doc "Fix the user's stale deb-based members among PRE-COMPUTED `members`, settling over PRE-COMPUTED \
            \ `reward-rows` — both batch-invariant, so a chunk fix scans FVT|T|ScoreEntityLink AND FVT|T|RPS|Global \
            \ ONCE, not once per user/member. require SECURE."
        (require-capability (SECURE))
        (map
            (lambda (member-id:string)
                (XI_FixUserMemberDebIn user-id fvt-id (UR_FVT-SEL|ScoreEntityType fvt-id member-id) member-id reward-rows))
            members)
        (UC_EmptyOc)
    )
    (defun XI_FixUserFvtDeb:object{IgnisCollectorV1.OutputCumulator}
        (user-id:string fvt-id:string)
        @doc "Fix ALL of a user's stale deb-based members in the FVT. Single-user convenience (one member scan); \
            \ bulk callers use XI_FixUserFvtDebIn with a hoisted member list."
        (require-capability (SECURE))
        (XI_FixUserFvtDebIn user-id fvt-id (URH_FvtEnabledScoreEntityIdsForFvt fvt-id) (URH_FVT-RG|EnabledRewardRows fvt-id))
    )
    (defun XI_FixUserFvtDebPenalized:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string reward-dptf-id:string user-id:string)
        @doc "ENFORCED-INJECT variant: fix ALL the user's stale members (XI_FixUserFvtDeb) AND record the 2e \
            \ forced-fix count on (fvt, reward-dptf, user) = how many members were stale (counted BEFORE the fix). \
            \ The user pays that × RATE non-discountable IGNIS at his next collect of this lane. Self-fixing at \
            \ collect (PHASE 6) uses plain XI_FixUserFvtDeb and is NOT penalized. require SECURE."
        (require-capability (SECURE))
        (XI_FixUserFvtDebPenalizedIn fvt-id reward-dptf-id user-id (URH_FvtEnabledScoreEntityIdsForFvt fvt-id) (URH_FVT-RG|EnabledRewardRows fvt-id))
    )
    (defun XI_FixUserFvtDebPenalizedIn:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string reward-dptf-id:string user-id:string members:[string] reward-rows:[string])
        @doc "Hoisted twin of XI_FixUserFvtDebPenalized: count + fix the user's stale members among PRE-COMPUTED \
            \ `members`, settling over PRE-COMPUTED `reward-rows` (count + fix + settle all reuse the ONE member \
            \ list AND ONE reward-rows list — no per-user re-scan). require SECURE."
        (require-capability (SECURE))
        (let
            (
                (n:integer (URC_FvtUserStaleMemberCountIn fvt-id user-id members))
            )
            (XI_FixUserFvtDebIn user-id fvt-id members reward-rows)
            (WU_FvtForcedFixCount|Add fvt-id reward-dptf-id user-id n)
            (UC_EmptyOc)
        )
    )
    ;; --- Shared inject-CORE + cross-module XE_ building blocks (CC_Inject FVT-local; MTX|n|C_Inject via MTX-AQP) ---
    (defun XI_DistributeInjectAmount:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Escrow-aware distribution of `amount` (already in AQP|SC_NAME custody) to the CURRENT stakers of one \
            \ reward lane — the shared PHASE 2+3 core used by BOTH an instant inject (XI_FvtInjectCore) and a stream \
            \ drip (XI_ReleaseStream), so a streamed release is IDENTICAL to an instant inject of the same amount. \
            \ FLUSH (divisor > 0): R_eff = amount + zombie; FARM split-at-inject over fresh S, VAULT/TREASURY \
            \ G += R_eff / deb-sum; available-rewards += R_eff; zombie → 0. ESCROW (divisor 0, no stakers): hold \
            \ `amount` as zombie-rewards, touch nothing else (kept out of the M1 last-claimant sweep). require SECURE."
        (require-capability (SECURE))
        (let
            (
                (zombie:decimal (UR_FVT-RG|ZombieRewards fvt-id reward-dptf-id))
                (denominator:decimal
                    (if (= (UR_FVT|FvtClass fvt-id) 0)
                        (URC_FarmInjectDenominatorFresh fvt-id)
                        (URC_InjectDenominator fvt-id)
                    )
                )
            )
            (if (> denominator 0.0)
                ;; FLUSH — distribute amount + any escrowed zombie to the CURRENT stakers.
                (let
                    (
                        (eff:decimal (+ amount zombie))
                    )
                    (let
                        (
                            ;; farm split RETURNS the DSA uptime shortfall (0 for a normal farm); vault/treasury has none.
                            (royalty:decimal
                                (if (= (UR_FVT|FvtClass fvt-id) 0)
                                    (XI_1|FarmSplitInject fvt-id reward-dptf-id eff denominator)
                                    (do
                                        (WU_RpsGlobal|CurrentRps fvt-id reward-dptf-id
                                            (+ (UR_FVT-RG|CurrentRps fvt-id reward-dptf-id)
                                               (UC_ComputeInjectGainedRps eff denominator)))
                                        0.0)
                                )
                            )
                        )
                        ;; available-rewards enters G only NOW (the flush) — bump by R_eff MINUS the DSA uptime
                        ;; shortfall (royalty is 0 for a normal farm / vault ⇒ the full R_eff, exactly as before).
                        (WU_RpsGlobal|AvailableRewards fvt-id reward-dptf-id
                            (+ (UR_FVT-RG|AvailableRewards fvt-id reward-dptf-id) (- eff royalty)))
                        ;; DSA: the uptime shortfall accrues to the royalty pool (custodied, out of available / G /
                        ;; the M1 last-claimant sweep). Skip the write when there is none (non-delegation / full uptime).
                        (if (> royalty 0.0)
                            (WU_RpsGlobal|RoyaltyRewards fvt-id reward-dptf-id
                                (+ (UR_FVT-RG|RoyaltyRewards fvt-id reward-dptf-id) royalty))
                            "no royalty")
                        ;; zombie fully consumed by this flush (skip the write when there was none).
                        (if (> zombie 0.0)
                            (WU_RpsGlobal|ZombieRewards fvt-id reward-dptf-id 0.0)
                            "no escrow to clear")
                    )
                )
                ;; ESCROW — no stakers (divisor 0): park `amount` in limbo, available-rewards untouched.
                (WU_RpsGlobal|ZombieRewards fvt-id reward-dptf-id (+ zombie amount))
            )
            (UC_EmptyOc)
        )
    )
    (defun XI_ReleaseStream:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string reward-dptf-id:string)
        @doc "The DRIP / checkpoint for one reward lane. Releases the vested-since-last-drip slice of every active \
            \ stream and distributes it via XI_DistributeInjectAmount (so a stream === an instant inject of that \
            \ slice; a zero-weight interval escrows to zombie). Per stream: rel = min(rate * elapsed, amount - \
            \ released), or the exact remainder once finished (flush → zero dust). Survivors are compacted to \
            \ positions 1..k; finished streams are pruned (freeing slots). Fast no-op when stream-count = 0. \
            \ require SECURE (writes G / available-rewards / the stream ledger)."
        (require-capability (SECURE))
        (let ((count:integer (UR_FVT-RG|StreamCount fvt-id reward-dptf-id)))
            (if (= count 0)
                (UC_EmptyOc)                                        ;; fast path — no stream on this lane
                (let*
                    (
                        (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                        (now:time (at "block-time" (chain-data)))
                        (last:time (UR_FVT-RG|StreamLastRelease fvt-id reward-dptf-id))
                        ;; released amounts must be conformant to the reward token's precision — rate*elapsed is a
                        ;; high-precision product, so FLOOR each slice to the token's decimals (the finish-flush later
                        ;; releases amount-released, recovering the accumulated crumbs → exact per-stream conservation).
                        (reward-dec:integer (ref-DPTF::UR_Decimals reward-dptf-id))
                        ;; walk positions 1..count → { total released this drip, survivor rows (released advanced) }
                        (walk:object
                            (fold
                                (lambda (acc:object idx:integer)
                                    (let*
                                        (
                                            (s:object{FVT|RPS|Stream} (UR_FVT-RS|Stream fvt-id reward-dptf-id idx))
                                            (remaining:decimal (- (at "amount" s) (at "released" s)))
                                            (finished:bool (>= now (at "finish" s)))
                                            (rel:decimal
                                                (if finished
                                                    remaining                             ;; exact-remainder flush
                                                    (let ((by-rate:decimal (floor (* (at "rate" s) (diff-time now last)) reward-dec)))
                                                        (if (> by-rate remaining) remaining by-rate))))
                                        )
                                        { "total" : (+ (at "total" acc) rel)
                                        , "keep"  :
                                            (if finished
                                                (at "keep" acc)                           ;; pruned — freed slot
                                                (+ (at "keep" acc)
                                                   [ (UDC_FVT|RPS|Stream (at "rate" s) (at "finish" s) (at "amount" s)
                                                        (+ (at "released" s) rel) fvt-id reward-dptf-id idx) ]))
                                        }
                                    )
                                )
                                { "total" : 0.0, "keep" : [] }
                                (enumerate 1 count)
                            )
                        )
                        (total:decimal (at "total" walk))
                        (survivors:[object{FVT|RPS|Stream}] (at "keep" walk))
                        (k:integer (length survivors))
                    )
                    ;; 1. distribute the released slice (also flushes escrowed zombie; zero-weight interval → zombie)
                    (if (> total 0.0) (XI_DistributeInjectAmount fvt-id reward-dptf-id total) (UC_EmptyOc))
                    ;; 2. rewrite survivors compacted to positions 1..k (position field re-stamped)
                    (if (> k 0)
                        (map
                            (lambda (i:integer)
                                (let ((r:object{FVT|RPS|Stream} (at i survivors)))
                                    (WW_RpsStream fvt-id reward-dptf-id (+ i 1)
                                        (UDC_FVT|RPS|Stream (at "rate" r) (at "finish" r) (at "amount" r)
                                            (at "released" r) fvt-id reward-dptf-id (+ i 1)))))
                            (enumerate 0 (- k 1)))
                        "no survivors")
                    ;; 3. update the lane cursor
                    (WU_RpsGlobal|StreamCount fvt-id reward-dptf-id k)
                    (WU_RpsGlobal|StreamUnreleased fvt-id reward-dptf-id
                        (- (UR_FVT-RG|StreamUnreleased fvt-id reward-dptf-id) total))
                    (WU_RpsGlobal|StreamLastRelease fvt-id reward-dptf-id now)
                    (UC_EmptyOc)
                )
            )
        )
    )
    (defun XI_FvtInjectCore:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "THE single inject-CORE for ALL FVT classes — the ONLY place inject writes exist. C_Inject, CC_Inject \
            \ and the MTX|n|C_Inject defpact terminal step all route through here (one code path to audit/fix). \
            \ (1) custody transfer R patron→AQP|SC_NAME; (2) escrow-aware distribute over the divisor — FARM \
            \ (class 0): S = fresh split-at-inject value-sum, distribute (amount + zombie) across members via \
            \ XI_1|FarmSplitInject; VAULT/TREASURY: divisor = maintained total-deb-score mirror, G += (amount + \
            \ zombie) / divisor. FLUSH (divisor > 0): available-rewards += (amount + zombie), zombie→0. ESCROW \
            \ (divisor = 0, no stakers): hold `amount` as zombie-rewards, available-rewards untouched; \
            \ (3) GAS|INJECT cumulator. Freshness is a CALLER concern: C_Inject is the naive path (distributes over \
            \ the CURRENT divisor); CC_Inject / the defpact FIX every stale member first so the divisor is live. \
            \ require SECURE. UrStoa ≡ XI_URV|UpdateVaultRPS/Supply."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;===>PHASE 0=== drip pending streams first (checkpoint) so an instant amount distributes on top of
                    ;; a freshly-released lane — a live stream + an instant inject in the same tx compose correctly.
                    (XI_ReleaseStream fvt-id reward-dptf-id)
                    ;;===>PHASE 1=== custody transfer · UrStoa ≡ C_Transfer / C_Transmit
                    (ref-TFT::C_Transfer reward-dptf-id patron AQP|SC_NAME amount true)
                    ;;===>PHASE 2+3=== escrow-aware distribute + available-rewards (shared with the stream drip).
                    ;; Reward tokens are ALREADY in custody. XI_DistributeInjectAmount handles both the FLUSH
                    ;; (divisor > 0 → farm split-at-inject / vault G bump, available-rewards += R_eff, zombie→0) and
                    ;; the ESCROW-on-empty case (divisor 0 → hold `amount` as zombie, kept out of the M1 sweep).
                    (XI_DistributeInjectAmount fvt-id reward-dptf-id amount)
                    ;; PHASE 4.1 — Do not reset unclaimed-count · UrStoa comment-only slot
                    (URCi_Inject fvt-id [fvt-id reward-dptf-id (format "{}" [amount])])
                ]
                []
            )
        )
    )
    (defun XI_FvtAddStream:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
        @doc "Streamed inject CORE (linear vesting). (0) DRIP pending streams (checkpoint + prune finished → free \
            \ slots); (0b) enforce a free stream slot on the POST-DRIP count under the FVT owner konto's Elite-tier \
            \ cap; (1) custody-transfer `amount` patron→AQP|SC_NAME (held, invisible to available-rewards until \
            \ dripped); (2) append a stream at the next compacted position (rate = amount/duration, finish = \
            \ now+duration, released 0) and bump the lane cursor (stream-count, stream-unreleased += amount, \
            \ stream-last-release = now). NO distribution here — later drips release it linearly. require SECURE."
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            ;; PHASE 0 — drip (checkpoint + prune finished streams) so the shared last-release is `now` before we add
            (let ((drip-oc:object{IgnisCollectorV1.OutputCumulator} (XI_ReleaseStream fvt-id reward-dptf-id)))
                ;; PHASE 0b — slot-cap on the POST-DRIP count (Elite tier of the FVT owner konto, D5)
                (enforce (< (UR_FVT-RG|StreamCount fvt-id reward-dptf-id) (URC_MaxStreamLanes owner-konto))
                    "FVT|Stream: stream slots full for this owner's Elite tier — use a direct (instant) inject")
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        drip-oc
                        ;; PHASE 1 — custody transfer `amount` into AQP|SC_NAME (held until dripped)
                        (ref-TFT::C_Transfer reward-dptf-id patron AQP|SC_NAME amount true)
                        ;; PHASE 2 — append the stream at the next compacted position + bump the lane cursor
                        (let*
                            (
                                (count:integer (UR_FVT-RG|StreamCount fvt-id reward-dptf-id))
                                (now:time (at "block-time" (chain-data)))
                                (new-pos:integer (+ count 1))
                            )
                            (WW_RpsStream fvt-id reward-dptf-id new-pos
                                (UDC_FVT|RPS|Stream (/ amount (dec duration)) (add-time now duration) amount 0.0
                                    fvt-id reward-dptf-id new-pos))
                            (WU_RpsGlobal|StreamCount fvt-id reward-dptf-id new-pos)
                            (WU_RpsGlobal|StreamUnreleased fvt-id reward-dptf-id
                                (+ (UR_FVT-RG|StreamUnreleased fvt-id reward-dptf-id) amount))
                            (WU_RpsGlobal|StreamLastRelease fvt-id reward-dptf-id now)
                            (UC_EmptyOc)
                        )
                        ;; PHASE 3 — GAS (same lane event as an instant inject)
                        (URCi_Inject fvt-id [fvt-id reward-dptf-id (format "{}" [amount])])
                    ]
                    []
                )
            )
        )
    )
    (defun XI_FvtSweepRecomputeChunk:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string score-entity-id:string swept-boost-class-id:string users:[string])
        @doc "Intra-module chunk: recompute a chunk of holders on one (fvt, member) after the swept anchor's global \
            \ removal — per user runs XI_SweepRecomputeUserMember (settle → aggregate/lane refold → deb + mirror). \
            \ NO fund movement, NO 2e penalty (owner sweep, D4). require SECURE. Shared by the intra-module client \
            \ CC_SweepRevokeAnchor and the cross-module wrapper XE_FvtSweepRecomputeChunk."
        (require-capability (SECURE))
        (let
            (
                (reward-rows:[string] (URH_FVT-RG|EnabledRewardRows fvt-id))
            )
            ;; DRIP each reward lane once (checkpoint) before the recompute loop → holders settle at now's index
            (map (lambda (d:string) (XI_ReleaseStream fvt-id d)) reward-rows)
            (map
                (lambda (u:string)
                    (XI_SweepRecomputeUserMemberIn u fvt-id (UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id) score-entity-id swept-boost-class-id reward-rows))
                users))
        (UC_EmptyOc)
    )
    (defun XI_FvtSweepRecomputeWindow:integer
        (score-ids:[string] boost-class-id:string win-lo:integer win-hi:integer)
        @doc "Recompute holders whose GLOBAL flattened index — present users concatenated across score-ids in \
            \ order — falls in [win-lo, win-hi). Per score, slice its present users to the window overlap and run \
            \ one XI_FvtSweepRecomputeChunk. sweep-in-progress makes URH_FvtPresentUsers order deterministic across \
            \ the CC-batch's txs, so (drop offset) pages without re-processing. Returns holders recomputed. The \
            \ intra-module (require SECURE) twin of MTX-AQP::XI_SweepRecomputeWindow (which forwards the SAME \
            \ per-member work via XE_FvtSweepRecomputeChunk) — both funnel through XI_FvtSweepRecomputeChunk, so \
            \ the defun+gate and defpact paths recompute identically. require SECURE."
        (require-capability (SECURE))
        (at "processed"
            (fold
                (lambda (acc:object sid:string)
                    (let
                        (
                            (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                            (seen-before:integer (at "seen" acc))
                            (fvt:string (ref-SCR::UR_SCR|ScoreFvtLink sid))
                            (member:string
                                (if (ref-SCR::UR_SCR|ScoreTriplet sid) (ref-SCR::UR_SCR|ScoreTripletId sid) sid))
                        )
                        (let
                            (
                                (users:[string] (URH_FvtPresentUsers fvt))
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
                                            (XI_FvtSweepRecomputeChunk fvt member boost-class-id slice)
                                            {"seen": seen-after, "processed": (+ (at "processed" acc) (length slice))})
                                        {"seen": seen-after, "processed": (at "processed" acc)}))))))
                {"seen": 0, "processed": 0}
                score-ids))
    )
    ;;
    ;; --- Block B · Phase 3 anchor refresh (CC_TrueFungibleStakeFlow · 3.1) ---
    ;;   XI_RefreshTrueFungibleStakeAnchors
    ;;     ├ AQP-ANK::XE_UpdateTrueFungibleUserAnchorValues
    ;;     └ AQP-POOL::XB_SetBenDptfAnkSyncCount
    ;;
    ;; --- Anchors (AQP-ANK · TF stake only) ---
    (defun XI_RefreshTrueFungibleStakeAnchors:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
        @doc "Internal (CC_TrueFungibleStakeFlow phase 3.1 · depth 0]): read post-ico1 BenDptfTotal balance, \
            \ call backward ANK promile refresh + AQP last-ank-sync-count bump; concat IGNIS OCs. \
            \ require-capability (SECURE) only — backward XE_* use P|UEV_IMC / domain caps."
        (require-capability (SECURE))
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (total-dptf-amount:decimal (ref-AQP::UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
                (ico-ank:object{IgnisCollectorV1.OutputCumulator}
                    (ref-ANK::XE_UpdateTrueFungibleUserAnchorValues beneficiary-id dptf-id total-dptf-amount)
                )
                (ico-aqp:object{IgnisCollectorV1.OutputCumulator}
                    (ref-AQP::XB_SetBenDptfAnkSyncCount beneficiary-id dptf-id)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico-ank ico-aqp] [])
        )
    )
    ;;
    ;; --- Block B′ · Phase 3 anchor refresh (CC_CollectableStakeFlow · 3.2 or 3.3 via son) ---
    ;;   XI_RefreshCollectableStakeAnchors
    ;;     ├ AQP-ANK::XE_UpdateSemiFungible* or XE_UpdateNonFungible*
    ;;     └ AQP-POOL::XB_SetBenCollectableAnkSyncCount
    ;;
    (defun XI_RefreshCollectableStakeAnchors:object{IgnisCollectorV1.OutputCumulator}
        (
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Internal (CC_CollectableStakeFlow phase 3]): ANK promile refresh — DPSF (son=true) or DPNF (son=false)."
        (require-capability (SECURE))
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
            )
            (if son
                (ref-ANK::XE_UpdateSemiFungibleUserAnchorValues
                    beneficiary-id collectable-id nonces nonce-amounts direction
                )
                (ref-ANK::XE_UpdateNonFungibleUserAnchorValues
                    beneficiary-id collectable-id nonces direction
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_MediumCumulator AQP|SC_NAME)
                    (ref-AQP::XB_SetBenCollectableAnkSyncCount beneficiary-id collectable-id son)
                ]
                []
            )
        )
    )
    ;;
    ;; --- Block B · Phase 2.35 unclaimed (C_*StakeFlow) ---
    ;;   XI_BookStakeUnclaimedCounts — map distinct-fvts × reward lines; child XI_2|BumpRpsGlobalUnclaimed.
    ;;
    (defun XI_2|BumpRpsGlobalUnclaimed
        (fvt-id:string reward-dptf-id:string direction:bool)
        @doc "Internal (phase 2.35 · depth 2]): increment/decrement FVT|T|RPS|Global.unclaimed-count (UrStoa XI_URV|UpdateUnclaimedCount)."
        ;; SECURE: granted by WU_RpsGlobal|UnclaimedCount (underlying W_).
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
            (WU_RpsGlobal|UnclaimedCount fvt-id reward-dptf-id new-uc)
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
        ;; SECURE: granted by XI_2|BumpRpsGlobalUnclaimed (underlying W_).
        (let
            (
                (was-claimant:bool
                    (fold (or) false
                        (map
                            (lambda (plan:object{FVT|SettleScorePlan})
                                (fold (or) false
                                    (map
                                        (lambda (score-id:string)
                                            (URC_PreScoreWasNonZeroForScore pre-nz-flags score-id)
                                        )
                                        (URC_SettlePlanEmployedScoreIds plan)
                                    )
                                )
                            )
                            plans
                        )
                    )
                )
                (is-claimant:bool
                    (fold (or) false
                        (map
                            (lambda (plan:object{FVT|SettleScorePlan})
                                (fold (or) false
                                    (map
                                        (lambda (score-id:string)
                                            (URC_UserScoreTripleIsNonZero beneficiary-id pool-id score-id)
                                        )
                                        (URC_SettlePlanEmployedScoreIds plan)
                                    )
                                )
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
            ;; #10 Tier-1: the SAME claimant transition, but per MEMBER (plan), drives that member's mini-vault
            ;; unclaimed-count — so the member sweep knows when its last user is collecting.
            (map
                (lambda (plan:object{FVT|SettleScorePlan})
                    (let
                        (
                            (m-entity:string (at "score-entity-id" plan))
                            (m-sids:[string] (URC_SettlePlanEmployedScoreIds plan))
                            (m-was:bool
                                (fold (or) false
                                    (map (lambda (sid:string) (URC_PreScoreWasNonZeroForScore pre-nz-flags sid)) m-sids)))
                            (m-is:bool
                                (fold (or) false
                                    (map (lambda (sid:string) (URC_UserScoreTripleIsNonZero beneficiary-id pool-id sid)) m-sids)))
                            (m-pending:bool
                                (> (UR_FVT-RU|PendingRewards beneficiary-id fvt-id m-entity reward-dptf-id) 0.0))
                        )
                        (if (and (not m-was) m-is)
                            (WU_MemberVault|UnclaimedCount fvt-id m-entity reward-dptf-id true)
                            (if (and m-was (not m-is))
                                (if (not m-pending)
                                    (WU_MemberVault|UnclaimedCount fvt-id m-entity reward-dptf-id false)
                                    true)
                                true))
                    )
                )
                plans
            )
        )
    )
    ;; --- RPS post-SCORE (UrStoa unclaimed + checkpoint) ---
    (defun XI_BookStakeUnclaimedCounts:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object{FVT|StakeSettleBundle})
        @doc "Internal (C_*StakeFlow phase 2.35 · depth 0]): RPS|Global unclaimed-count after SCORE (UrStoa XI_URV|UpdateUnclaimedCount). \
            \ Once per (fvt-id, reward-dptf-id) per tx — OR was/is claimant across employed scores on that fvt in this pool. \
            \ Decrement only when user leaves claimant set and has no pending on that reward line. \
            \ IGNIS interactor = AQP|SC_NAME."
        ;; SECURE: granted by XI_1|BookUnclaimedForFvtRewardLine (underlying W_).
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
    ;; --- Block C · checkpoint (C_*StakeFlow) ---
    ;;   XI_CheckpointStakeRps — nested map (score plan × reward line); no child XI_*.
    ;;
    (defun XI_CheckpointStakeRps:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object{FVT|StakeSettleBundle})
        @doc "Internal (C_*StakeFlow phase 2.4 · depth 0]): advance last-rps to NEW L_i after SCORE deb mutation (UrStoa XI_URV|UpdateUserRPS). \
            \ settle-bundle from URHC_BuildStakeSettleBundle (same scope as phase 2.1; no second URD). \
            \ Only existing FVT|T|RPS|User rows are updated. \
            \ IGNIS interactor = AQP|SC_NAME (pool vault receiver). Returns checkpoint IGNIS OC."
        ;; SECURE: granted by WU_RpsUser|LastRps (underlying W_).
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
                            (score-entity-type:integer (at "score-entity-type" plan))
                (score-entity-id:string (at "score-entity-id" plan))
                            (reward-dptf-ids:[string] (at "reward-dptf-ids" plan))
                        )
                        ;; map: reward DPTF lines — advance last-rps to NEW L_i on existing user rows only
                        (map
                            (lambda (reward-dptf-id:string)
                                (if (URC_FvtRpsUserRowExists beneficiary-id fvt-id score-entity-id reward-dptf-id)
                                    (WU_RpsUser|LastRps beneficiary-id fvt-id score-entity-id reward-dptf-id
                                        (URC_FvtTier1IndexRps fvt-id score-entity-id reward-dptf-id)
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
    (defun XI_1|HeterogeneousLaneRoute:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string mf-id:string amt-b:decimal amt-s:decimal amt-g:decimal prec:integer)
        @doc "Heterogeneous MULTIPLET_BASE collect: split EACH lane amount across the 3 ladder tokens per the \
            \ FVT|QualitySplit matrix (per-mille rows), aggregate the 3 tokens, and route total-t0 raw / total-t1 \
            \ via one ATS leg / total-t2 via two — reusing the homogeneous per-leg primitives (pre-fund token-0, \
            \ then Coil/Curl). total-t2 is the dust-free remainder. require SECURE."
        (require-capability (SECURE))
        (let
            (
                (ref-TFT:module{TrueFungibleTransferV1} TFT)
                (ref-ATSU:module{AutostakeUsageV1} ATSU)
                (ref-ATS:module{AutostakeV2} ATS)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (bs:[integer] (UR_FVT-QS|BronzeSplit fvt-id reward-dptf-id))
                (ss:[integer] (UR_FVT-QS|SilverSplit fvt-id reward-dptf-id))
                (gs:[integer] (UR_FVT-QS|GoldSplit fvt-id reward-dptf-id))
                (token-0:string (UR_FVT-MF|Token0Id mf-id))
                (ats-01:string (UR_FVT-MF|Ats01Id mf-id))
                (ats-12:string (UR_FVT-MF|Ats12Id mf-id))
                ;; per-lane token-0/token-1 slices (per-mille); token-2 is the remainder, aggregated below
                (b0:decimal (floor (/ (* amt-b (dec (at 0 bs))) 1000.0) prec))
                (b1:decimal (floor (/ (* amt-b (dec (at 1 bs))) 1000.0) prec))
                (s0:decimal (floor (/ (* amt-s (dec (at 0 ss))) 1000.0) prec))
                (s1:decimal (floor (/ (* amt-s (dec (at 1 ss))) 1000.0) prec))
                (g0:decimal (floor (/ (* amt-g (dec (at 0 gs))) 1000.0) prec))
                (g1:decimal (floor (/ (* amt-g (dec (at 1 gs))) 1000.0) prec))
                (total-t0:decimal (+ b0 (+ s0 g0)))
                (total-t1:decimal (+ b1 (+ s1 g1)))
                (total-t2:decimal (- (+ amt-b (+ amt-s amt-g)) (+ total-t0 total-t1)))
                (fund-12:decimal (+ total-t1 total-t2))
                (coil-ok:bool
                    (if (> total-t1 0.0)
                        (> (at "rbt-amount" (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 total-t1)) 0.0)
                        false))
                (curl-ok:bool
                    (if (> total-t2 0.0)
                        (let ((h1:object (ref-ATS::URC_RewardBearingTokenAmounts ats-01 token-0 total-t2)))
                            (if (> (at "rbt-amount" h1) 0.0)
                                (> (at "rbt-amount"
                                        (ref-ATS::URC_RewardBearingTokenAmounts ats-12 (at "rbt-id" h1) (at "rbt-amount" h1)))
                                   0.0)
                                false))
                        false))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (if (> total-t0 0.0) (ref-TFT::C_Transfer token-0 AQP|SC_NAME patron total-t0 true) (UC_EmptyOc))
                    (if (> fund-12 0.0) (ref-TFT::C_Transfer token-0 AQP|SC_NAME patron fund-12 true) (UC_EmptyOc))
                    (if coil-ok (ref-ATSU::C_Coil patron ats-01 token-0 total-t1) (UC_EmptyOc))
                    (if curl-ok (ref-ATSU::C_Curl patron ats-01 ats-12 token-0 total-t2) (UC_EmptyOc))
                ]
                []
            )
        )
    )
    (defun XI_NormalizeRoyalty:object (reward-dptf-id:string amount:decimal)
        @doc "IGNIS pre-normalization for a royalty disposal: if the royalty leg is IGNIS, COMPRESS it to OURO in \
            \ AQP|SC_NAME custody (OUROBOROS::XB_Compress, 98.5%) and return {token: OURO, amount: OURO-received, \
            \ oc: compress-cumulator}; else return {token, amount, oc: empty} unchanged. The disposal then moves \
            \ the normalized token — IGNIS can be neither withdrawn nor fueled as a token, so it is always \
            \ converted first. require SECURE (the disposal cap holds P|SECURE-CALLER + P|FVT|REMOTE-GOV, so the \
            \ IGNIS custody legs inside XB_Compress are authorized)."
        (require-capability (SECURE))
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
            )
            (if (= reward-dptf-id (ref-DALOS::UR_IgnisID))
                (let
                    (
                        (ref-ORBR:module{OuroborosV1} OUROBOROS)
                    )
                    {"token"  : (ref-DALOS::UR_OuroborosID)
                    ,"amount" : (at 0 (ref-ORBR::URC_Compress amount))
                    ,"oc"     : (ref-ORBR::XB_Compress AQP|SC_NAME amount)}
                )
                {"token" : reward-dptf-id, "amount" : amount, "oc" : (UC_EmptyOc)}
            )
        )
    )
    ;; [XE]
    (defun XE_FvtFixUserChunk:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string reward-dptf-id:string users:[string])
        @doc "Forward (MTX-AQP defpact step): FIX a chunk of stale stakers in the FVT (settle + refresh + \
            \ mirror-resync per user; each fresh member no-ops), recording the 2e forced-fix count per user on \
            \ `reward-dptf-id` (the injected lane). NO fund movement. Caller passes `take N` of \
            \ URH_FvtStalePresentUsers. Computes the FVT's enabled members ONCE and reuses it across the chunk (no \
            \ per-user FVT|T|ScoreEntityLink re-scan). P|UEV_IMC + FVT|XE>SWEEP-FIX (composes SECURE)."
        (P|UEV_IMC)
        (with-capability (FVT|XE>SWEEP-FIX fvt-id)
            (let
                (
                    (members:[string] (URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
                    (reward-rows:[string] (URH_FVT-RG|EnabledRewardRows fvt-id))
                )
                ;; DRIP each reward lane once (checkpoint) before the fix loop → users settle at now's index
                (map (lambda (d:string) (XI_ReleaseStream fvt-id d)) reward-rows)
                (map (lambda (u:string) (XI_FixUserFvtDebPenalizedIn fvt-id reward-dptf-id u members reward-rows)) users))
            (UC_EmptyOc)
        )
    )
    (defun XE_SweepSyncTripletLaneWeights:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string fvt-id:string score-entity-id:string)
        @doc "Forward (re-score sweep): re-snapshot a TRUE-triplet member's Level-1 lane weight for this holder at \
            \ the LIVE promile (after an anchor change) and delta-adjust ScoreEntityLink.total-lane-weight — the \
            \ triplet analogue of ANK::XE_RecomputeUserBoostAggregates / SCR::XE_RefreshUserScoreDeb (true-triplets \
            \ are deb-independent; their anchor staleness lives in the lanes). Self-no-ops for non-true-triplet / \
            \ singular members (XI_SyncTripletLaneWeights guards on the true-triplet flag). NO fund movement; the \
            \ sweep defpact bills IGNIS. P|UEV_IMC + FVT|XE>SWEEP-FIX (composes SECURE)."
        (P|UEV_IMC)
        (with-capability (FVT|XE>SWEEP-FIX fvt-id)
            (XI_SyncTripletLaneWeights beneficiary-id
                [(UDC_FVT|SettleScorePlan (UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id) score-entity-id fvt-id [])])
            (UC_EmptyOc)
        )
    )
    (defun XE_FvtSweepRecomputeChunk:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string score-entity-id:string swept-boost-class-id:string users:[string])
        @doc "Forward (re-score sweep defpact — cross-module): recompute a CHUNK of holders on one (fvt, member). \
            \ Thin P|UEV_IMC + FVT|XE>SWEEP-FIX (composes SECURE) wrapper over XI_FvtSweepRecomputeChunk. Caller passes \
            \ `take N` of the member's present users. Paged by MTX-AQP::C_MTX|2|SweepRevokeAnchor (XI_SweepRecomputeWindow)."
        (P|UEV_IMC)
        (with-capability (FVT|XE>SWEEP-FIX fvt-id)
            (XI_FvtSweepRecomputeChunk fvt-id score-entity-id swept-boost-class-id users)
        )
    )
    (defun XE_SweepBegin:string (anchor-id:string)
        @doc "Sweep bracket BEGIN (paginated MTX|n|C_SweepRevokeAnchor): freeze every affected pool (stake + collect \
            \ blocked) then remove the anchor globally (swept-revoke — skips the #9 score-link lock). Mirrors steps \
            \ 1-2 of the single-tx CC_SweepRevokeAnchor. P|UEV_IMC + FVT|XE>SWEEP-BRACKET (P|SECURE-CALLER)."
        (P|UEV_IMC)
        (with-capability (FVT|XE>SWEEP-BRACKET anchor-id)
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (score-ids:[string]
                        (ref-ANK::UR_BC|ScoreLinks (ref-ANK::UR_ANK|BoostClassId anchor-id)))
                )
                ;; 1. FREEZE every affected pool (idempotent per shared pool)
                (map (lambda (sid:string) (ref-AQP::XE_SetSweepInProgress (ref-SCR::UR_SCR|ScoreAqpoolLink sid) true)) score-ids)
                ;; 2. REVOKE the anchor globally (swept — keeps scores linked; the paged recompute un-stales everyone)
                (ref-ANK::XE_SweepRevokeAnchor anchor-id)
                (format "Sweep begun for anchor {}: froze {} affected pool(s), anchor swept-revoked." [anchor-id (length score-ids)])
            )
        )
    )
    (defun XE_SweepEnd:string (anchor-id:string)
        @doc "Sweep bracket END (paginated MTX|n|C_SweepRevokeAnchor terminal step): unfreeze every affected pool. \
            \ The anchor was already swept-revoked in XE_SweepBegin; the reverse index is unchanged so score-ids \
            \ still resolve. P|UEV_IMC + FVT|XE>SWEEP-BRACKET (P|SECURE-CALLER)."
        (P|UEV_IMC)
        (with-capability (FVT|XE>SWEEP-BRACKET anchor-id)
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (score-ids:[string]
                        (ref-ANK::UR_BC|ScoreLinks (ref-ANK::UR_ANK|BoostClassId anchor-id)))
                )
                (map (lambda (sid:string) (ref-AQP::XE_SetSweepInProgress (ref-SCR::UR_SCR|ScoreAqpoolLink sid) false)) score-ids)
                (format "Sweep ended for anchor {}: unfroze {} affected pool(s)." [anchor-id (length score-ids)])
            )
        )
    )
    ;;
    ;; --- XE forwarders (AQP-VCT TF vacate composes stake/RPS primitives via IMC) ---
    (defun XE_SetFvtVacateFrozen:string (fvt-id:string frozen:bool)
        @doc "AQP-VCT begin/finalize: set this FVT's vacate-frozen flag (blocks collect + inject during a pool \
            \ vacate). Called once per the vacating pool's employed-score FVTs. P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (WU_FvtVacateFreeze fvt-id frozen)
        )
    )
    (defun XE_SetFvtOracleOn:string (fvt-id:string oracle-on:bool)
        @doc "DSA: toggle this FVT's node/uptime oracle (off ⇒ capture = units, uptime ≡ 1000, no expiry). P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (WU_Fvt|OracleOn fvt-id oracle-on)
        )
    )
    (defun XE_SetExternalOracle:string (on:bool)
        @doc "DSA (module admin): set the GLOBAL external-oracle switch. Preserves the current oracle-validity. \
            \ P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (with-default-read FVT|T|DsaOracleConfig FVT|DSA-ORACLE-KEY
                {"oracle-validity" : DSA_ORACLE_TTL} {"oracle-validity" := v}
                (write FVT|T|DsaOracleConfig FVT|DSA-ORACLE-KEY {"external-oracle" : on, "oracle-validity" : v})
            )
        )
    )
    (defun XE_SetOracleValidity:string (seconds:integer)
        @doc "DSA (module admin): set the GLOBAL oracle-validity window (seconds). Preserves the current \
            \ external-oracle switch. P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (with-default-read FVT|T|DsaOracleConfig FVT|DSA-ORACLE-KEY
                {"external-oracle" : true} {"external-oracle" := x}
                (write FVT|T|DsaOracleConfig FVT|DSA-ORACLE-KEY {"external-oracle" : x, "oracle-validity" : seconds})
            )
        )
    )
    (defun XE_SetAgencyFee:string (fvt-id:string score-entity-id:string operator-konto:string fee-per-mille:integer)
        @doc "DSA: set/update a delegation member's operator + fee (mirrored from DSA|Agency so the inject settle \
            \ reads it locally). Set at open + on a fee change. P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (WU_AgencyFee fvt-id score-entity-id operator-konto fee-per-mille)
        )
    )
    (defun XE_SetMemberDelegation:string (fvt-id:string score-entity-id:string delegation:bool)
        @doc "DSA: flip a member to (or from) a delegation agency. P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (WU_ScoreEntityLink|Delegation fvt-id score-entity-id delegation)
        )
    )
    (defun XE_SetMemberCapture:string (fvt-id:string score-entity-id:string capture-units:decimal capture-weight:decimal oracle-ts:time)
        @doc "DSA: set an agency's capture fields — the values the inject reads (numerator = capture-weight, \
            \ denominator term = capture-units, 25h expiry = oracle-ts). Recomputed by DSA on delegator \
            \ stake/unstake or an oracle write. P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (WU_ScoreEntityLink|Capture fvt-id score-entity-id capture-units capture-weight oracle-ts)
        )
    )
    (defun XE_AdmitDelegationMember:string (fvt-id:string triplet-id:string operator:string)
        @doc "DSA: admit an OPERATOR-owned triplet as a delegation agency member on a class-0 DSA vault FVT — \
            \ vault-like (swpair \"|\", ghost 0; inject weight = capture). Creates the three SCR fvt-links + inserts \
            \ the ScoreEntityLink via the same write path as C_AddScoreEntity, but validated by \
            \ FVT|XE>ADMIT-DELEGATION (operator ownership, LP-farm rules skipped). DSA flips `delegation` on via \
            \ XE_SetMemberDelegation after this. P|UEV_IMC + FVT|XE>ADMIT-DELEGATION."
        (P|UEV_IMC)
        (with-capability (FVT|XE>ADMIT-DELEGATION fvt-id triplet-id operator)
            (let
                (
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-SCR::XE_CreateFvtLink (ref-SCR::UR_SCR|TripletBronzeScoreId triplet-id) fvt-id)
                (ref-SCR::XE_CreateFvtLink (ref-SCR::UR_SCR|TripletSilverScoreId triplet-id) fvt-id)
                (ref-SCR::XE_CreateFvtLink (ref-SCR::UR_SCR|TripletGoldenScoreId triplet-id) fvt-id)
                (XI_AddScoreEntity fvt-id CT_SCORE_ENTITY_TRIPLET triplet-id "|" 0.0)
            )
        )
    )
    (defun XE_WithdrawRoyalty:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string reward-dptf-id:string destination:string)
        @doc "DSA royalty disposal (WITHDRAW): zero the royalty pool (reward-dptf) of <fvt-id>, IGNIS-normalize it \
            \ to OURO if needed, and move the whole balance OUT of the AQP pool-vault custody (AQP|SC_NAME) to \
            \ <destination> via TFT. P|UEV_IMC + FVT|XE>DISPOSE-ROYALTY (composes P|SECURE-CALLER + P|FVT|REMOTE-GOV \
            \ for the AQP custody leg). Returns the (compress + transfer) OutputCumulator. Owner authorization is \
            \ enforced upstream in DSA's A_ shell."
        (P|UEV_IMC)
        (with-capability (FVT|XE>DISPOSE-ROYALTY fvt-id reward-dptf-id)
            (let
                (
                    (ref-TFT:module{TrueFungibleTransferV1} TFT)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (royalty:decimal (UR_FVT-RG|RoyaltyRewards fvt-id reward-dptf-id))
                )
                (WU_RpsGlobal|RoyaltyRewards fvt-id reward-dptf-id 0.0)
                (let
                    (
                        (norm:object (XI_NormalizeRoyalty reward-dptf-id royalty))
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [ (at "oc" norm)
                          (ref-TFT::C_Transfer (at "token" norm) AQP|SC_NAME destination (at "amount" norm) true) ]
                        [destination])
                )
            )
        )
    )
    (defun XE_BurnRoyalty:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string reward-dptf-id:string)
        @doc "DSA royalty disposal (BURN): zero the royalty pool (reward-dptf) of <fvt-id>, IGNIS-normalize it to \
            \ OURO if needed, and BURN the whole balance in place from the AQP pool-vault custody (AQP|SC_NAME — \
            \ which holds the autonomic burn role via DALOS UR_AutonomicRoles; FVT is a registered DPTF IMC caller). \
            \ P|UEV_IMC + FVT|XE>DISPOSE-ROYALTY. Returns the (compress + burn) OutputCumulator."
        (P|UEV_IMC)
        (with-capability (FVT|XE>DISPOSE-ROYALTY fvt-id reward-dptf-id)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (royalty:decimal (UR_FVT-RG|RoyaltyRewards fvt-id reward-dptf-id))
                )
                (WU_RpsGlobal|RoyaltyRewards fvt-id reward-dptf-id 0.0)
                (let
                    (
                        (norm:object (XI_NormalizeRoyalty reward-dptf-id royalty))
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [ (at "oc" norm)
                          (ref-DPTF::C_Burn (at "token" norm) AQP|SC_NAME (at "amount" norm)) ]
                        [reward-dptf-id])
                )
            )
        )
    )
    (defun XE_FuelRoyalty:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string reward-dptf-id:string swpair:string)
        @doc "DSA royalty disposal (FUEL): zero the royalty pool (reward-dptf) of <fvt-id>, IGNIS-normalize it to \
            \ OURO if needed, and FUEL <swpair> with the whole balance from the AQP pool-vault custody — adds \
            \ liquidity WITHOUT minting LP (SWPLC::C_Fuel), boosting LP value. The NORMALIZED token must be one of \
            \ the swpair's tokens; the fuel amount goes in its slot, 0 in the others. P|UEV_IMC + FVT|XE>DISPOSE-ROYALTY \
            \ (P|FVT|REMOTE-GOV custody authority). FVT is a registered SWPLC IMC caller. Returns the (compress + \
            \ fuel) OutputCumulator."
        (P|UEV_IMC)
        (with-capability (FVT|XE>DISPOSE-ROYALTY fvt-id reward-dptf-id)
            (let
                (
                    (ref-SWP:module{SwapperV3} SWP)
                    (ref-SWPLC:module{SwapperLiquidityClientV1} SWPLC)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (royalty:decimal (UR_FVT-RG|RoyaltyRewards fvt-id reward-dptf-id))
                )
                (WU_RpsGlobal|RoyaltyRewards fvt-id reward-dptf-id 0.0)
                (let
                    (
                        (norm:object (XI_NormalizeRoyalty reward-dptf-id royalty))
                        (pool-tokens:[string] (ref-SWP::UR_PoolTokens swpair))
                    )
                    (enforce (contains (at "token" norm) pool-tokens) "Normalized royalty token is not a token of the swpair")
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [ (at "oc" norm)
                          (ref-SWPLC::C_Fuel AQP|SC_NAME swpair
                              (map (lambda (t:string) (if (= t (at "token" norm)) (at "amount" norm) 0.0)) pool-tokens)
                              true true) ]
                        [reward-dptf-id])
                )
            )
        )
    )
    (defun XE_BankScorePendingRewards:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string plan:object)
        @doc "Forward (stake/unstake/collect flow): bank the beneficiary's pending per-score rewards for \
            \ <pool-id> into the claimable ledger following <plan> (the pre-computed settle plan). P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (do
                (XI_1|BankScorePendingRewards beneficiary-id pool-id plan)
                (UC_EmptyOc)
            )
        )
    )
    (defun XE_RefreshTrueFungibleStakeAnchors:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
        @doc "Forward (stake/unstake flow): recompute the beneficiary's true-fungible stake-anchor values for \
            \ <dptf-id> after a stake delta, keeping the anchor aggregates in sync with the live stake. P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_RefreshTrueFungibleStakeAnchors beneficiary-id dptf-id)
        )
    )
    (defun XE_RefreshCollectableStakeAnchors:object{IgnisCollectorV1.OutputCumulator}
        (
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
        @doc "Forward (stake/unstake flow): recompute the beneficiary's collectable (SF/NF) stake-anchor values \
            \ for <collectable-id>'s <nonces>/<nonce-amounts> in <direction> (stake vs unstake), keeping the \
            \ anchor aggregates in sync with the live nonce stake. P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_RefreshCollectableStakeAnchors
                beneficiary-id collectable-id son nonces nonce-amounts direction
            )
        )
    )
    (defun XE_BookStakeUnclaimedCounts:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object)
        @doc "Forward (stake/unstake/collect flow): book the beneficiary's unclaimed-reward counts for \
            \ <pool-id> from <settle-bundle> so later collects settle the correct outstanding units. P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_BookStakeUnclaimedCounts beneficiary-id pool-id settle-bundle)
        )
    )
    (defun XE_CheckpointStakeRps:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object)
        @doc "Forward (stake/unstake/collect flow): checkpoint the beneficiary's reward-per-share (RPS) baseline \
            \ for <pool-id> from <settle-bundle> so subsequent accrual is measured from the new stake state. P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_CheckpointStakeRps beneficiary-id pool-id settle-bundle)
        )
    )
    ;; [XB]
    (defun XB_FvtInject:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "THE single authorized inject entry — usable BOTH internally (C_Inject delegates here) and externally \
            \ (the MTX|n|C_Inject defpact terminal step calls it cross-module), hence `XB`. Just the auth wrapper: \
            \ P|UEV_IMC + FVT|C>INJECT (validates + composes SECURE) around the one XI_FvtInjectCore. Any FVT class \
            \ (farm/vault/treasury); the core branches on class. Distributes over the CURRENT divisor — enforced- \
            \ fresh callers (CC_Inject / the defpact) fix stale members BEFORE calling. Replaces the former \
            \ XE_FvtInject: after the class-guard removal (N2) it was byte-identical to C_Inject's body, so the two \
            \ collapsed onto this one XB entry."
        (P|UEV_IMC)
        (with-capability (FVT|C>INJECT patron fvt-id reward-dptf-id amount)
            (XI_FvtInjectCore patron fvt-id reward-dptf-id amount)
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;; [C]   client
    ;; --- Lifecycle (FVT|T) ---
    (defun C_Issue:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
        @doc "Create a new FVT (Farm | Vault | Treasury). GAS|ISSUE-FVT + smart STOA from patron; returns fvt-id in output."
        (P|UEV_IMC)
        (with-capability (FVT|C>ISSUE-FVT fvt-name owner-konto fvt-class common-denominator)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV1} DALOS)
                    (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    ;;
                    (smart-price:decimal (ref-DALOS::UR_UsagePrice "smart"))
                    (fvt-id:string (ref-U|DALOS::UDC_Makeid fvt-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::C_STOA|Collect patron (URCi_IssueStoa))
                (XI_IssueFvt fvt-id fvt-class owner-konto common-denominator)
                (URCi_Issue owner-konto [fvt-id])
            )
        )
    )
    ;;Management (FVT|Schema)
    (defun C_RotateOwnership:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string new-owner-konto:string)
        @doc "Transfer FVT owner-konto. Validation in FVT|C>ROTATE-OWNERSHIP-FVT; medium IGNIS on pre-rotate owner."
        (P|UEV_IMC)
        (let
            (
                (ico:object{IgnisCollectorV1.OutputCumulator} (URCi_RotateOwnership fvt-id))
            )
            (with-capability (FVT|C>ROTATE-OWNERSHIP-FVT fvt-id new-owner-konto)
                (XI_RotateOwnership fvt-id new-owner-konto)
            )
            ico
        )
    )
    (defun C_Control:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Set can-upgrade and can-change-owner on FVT. Medium IGNIS on owner-konto."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
            )
            (with-capability (FVT|C>CONTROL-FVT fvt-id new-can-upgrade new-can-change-owner)
                (XI_Control fvt-id new-can-upgrade new-can-change-owner)
            )
            (URCi_Control fvt-id)
        )
    )
    (defun C_SetCommonDenominator:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string common-denominator:string)
        @doc "Farm-only: set common-denominator before any ScoreEntityLinks. GAS|SET-COMMON-DENOMINATOR on owner."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>SET-COMMON-DENOMINATOR fvt-id common-denominator)
                (XI_SetCommonDenominator fvt-id common-denominator)
            )
            (URCi_SetCommonDenominator fvt-id [fvt-id])
        )
    )
    (defun C_SetMosaic:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string mosaic:bool)
        @doc "Toggle mosaic membership policy when FVT has no ScoreEntityLink rows. GAS|SET-MOSAIC on owner."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>SET-MOSAIC fvt-id mosaic)
                (XI_SetMosaic fvt-id mosaic)
            )
            (URCi_SetMosaic fvt-id [fvt-id])
        )
    )
    (defun C_SetSplitMode:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string split-mode:string)
        @doc "Set the farm reward-split mode (D1-G2): SPLIT|STAKED (participation, default) | SPLIT|TVL (pool-size). \
            \ Farm owner; FREELY mutable (no cooldown) — a change re-weights only FUTURE injects (RPS is \
            \ checkpoint-based, past rewards untouched). GAS|SET-SPLIT-MODE on owner."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>SET-SPLIT-MODE fvt-id split-mode)
                (XI_SetSplitMode fvt-id split-mode)
            )
            (URCi_SetSplitMode fvt-id [fvt-id split-mode])
        )
    )
    ;; --- Score membership (FVT|T|ScoreEntityLink) ---
    (defun C_AddScoreEntity:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "Register score (type 1) or triplet (type 3) on FVT; insert ScoreEntityLink; SCR fvt-links. GAS|ADD-SCORE-ENTITY."
        (P|UEV_IMC)
        (let
            (
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (fvt-class:integer (UR_FVT|FvtClass fvt-id))
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                (swpair:string (URC_ResolveScoreEntitySwpair score-entity-type score-entity-id fvt-class))
                (ghost-weight:decimal (URC_ResolveScoreEntityGhostWeight score-entity-type score-entity-id fvt-class swpair))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>ADD-SCORE-ENTITY fvt-id score-entity-type score-entity-id swpair ghost-weight)
                (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                    (let
                        (
                            (bronze-id:string (ref-SCR::UR_SCR|TripletBronzeScoreId score-entity-id))
                            (silver-id:string (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                            (golden-id:string (ref-SCR::UR_SCR|TripletGoldenScoreId score-entity-id))
                        )
                        (ref-SCR::XE_CreateFvtLink bronze-id fvt-id)
                        (ref-SCR::XE_CreateFvtLink silver-id fvt-id)
                        (ref-SCR::XE_CreateFvtLink golden-id fvt-id)
                    )
                    (ref-SCR::XE_CreateFvtLink score-entity-id fvt-id)
                )
                (XI_AddScoreEntity fvt-id score-entity-type score-entity-id swpair ghost-weight)
            )
            (URCi_AddScoreEntity fvt-id [fvt-id score-entity-id])
        )
    )
    (defun C_ToggleScoreEntityLink:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
        @doc "Turn ScoreEntityLink.enabled on/off; farm adjusts S when toggling. GAS|TOGGLE-SCORE-ENTITY-LINK."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>TOGGLE-SCORE-ENTITY-LINK fvt-id score-entity-type score-entity-id enabled)
                (XI_ToggleScoreEntityLink fvt-id score-entity-id enabled)
            )
            (URCi_ToggleScoreEntityLink fvt-id [fvt-id score-entity-id])
        )
    )
    (defun C_IssueMultipletFamily:object{IgnisCollectorV1.OutputCumulator}
        (
            patron:string
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
        )
        @doc "Issue one chain-wide MultipletFamily reward ladder F|t0|t1|t2."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (family-id:string (UCk_MultipletFamily token-0-id token-1-id token-2-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>ISSUE-MULTIPLET-FAMILY token-0-id token-1-id token-2-id ats-0-1-id ats-1-2-id)
                (XI_IssueMultipletFamily token-0-id token-1-id token-2-id ats-0-1-id ats-1-2-id)
            )
            (URCi_IssueMultipletFamily patron [family-id])
        )
    )
    ;; --- Reward token registration (FVT|T|RPS|Global) — atomic one row per reward DPTF ---
    (defun C_AddRewardLink:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
        @doc "Register one reward DPTF on FVT (single RPS|Global row). multiplet-family-id BAR for plain tokens (VESTA, etc.); \
            \ F|t0|t1|t2 when reward-dptf-id is family token-0 — enables triplet lane collect on triplet anchors; score anchors stay plain. \
            \ One inject feeds all membership tranches; collect branches on anchor-id (score vs triplet)."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                (reward-kind:string
                    (if (= multiplet-family-id BAR)
                        CT_REWARD_KIND_PLAIN
                        CT_REWARD_KIND_MULTIPLET_BASE
                    )
                )
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>ADD-REWARD-LINK fvt-id reward-dptf-id segmentation reward-kind multiplet-family-id)
                (XI_AddRewardLink fvt-id reward-dptf-id segmentation reward-kind multiplet-family-id)
            )
            (URCi_AddRewardLink fvt-id [fvt-id reward-dptf-id multiplet-family-id])
        )
    )
    (defun C_ToggleRewardLink:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Toggle reward-enabled; ±1 enabled-reward-count on flip. GAS|TOGGLE-REWARD-LINK on owner."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>TOGGLE-REWARD-LINK fvt-id reward-dptf-id enabled)
                (XI_ToggleRewardLink fvt-id reward-dptf-id enabled)
            )
            (URCi_ToggleRewardLink fvt-id [fvt-id reward-dptf-id])
        )
    )
    (defun C_SetQualitySplit:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
        @doc "Round B: set a MULTIPLET_BASE reward's quality-split MODE + heterogeneous MATRIX. HOMOGENEOUS (default \
            \ when unset) routes each quality lane to its one ladder token (bronze->t0, silver->t1, gold->t2). \
            \ HETEROGENEOUS routes each lane across ALL 3 ladder tokens per its [to-t0 to-t1 to-t2] per-mille row \
            \ (each row sums to 1000). FVT owner; O(1) reprice (no per-delegator recompute). GAS|SET-QUALITY-SPLIT."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>SET-QUALITY-SPLIT fvt-id reward-dptf-id mode bronze-split silver-split gold-split)
                (WI_QualitySplit fvt-id reward-dptf-id mode bronze-split silver-split gold-split)
            )
            (URCi_SetQualitySplit fvt-id [fvt-id reward-dptf-id mode])
        )
    )
    ;;
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;; UrStoa canonical inject / collect — phased model (00_StoaSandbox/coin.pact)
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;;
    ;; INJECT — C_URV|Inject / XI_URV|Inject
    ;; PHASE 0 — FVT farm pre-inject (architecture adaptation; UrStoa ≡ N/A):
    ;;   0.1 Ghost TVL lazy sync (all enabled ScoreEntityLinks)   XI_1|SyncFarmGhostTvlForEmployedScores
    ;; PHASE 1 — Custody (coin step 0):
    ;;   1.1 Transfer reward DPTF patron → AQP|SC_NAME      TFT::C_Transfer
    ;; PHASE 2 — RPS global index (coin step 1 · XI_URV|UpdateVaultRPS):
    ;;   2.1 current-rps G += floor(R / S, 48)              WU_RpsGlobal|CurrentRps
    ;; PHASE 3 — Reward vault balance (coin step 2 · XI_URV|UpdateVaultSupply):
    ;;   3.1 available-rewards += R                           WU_RpsGlobal|AvailableRewards
    ;; PHASE 4 — Unclaimed policy (coin step 3 · comment-only):
    ;;   4.1 Do NOT reset unclaimed-count on inject         N/A
    ;;
    ;; COLLECT — C_URV|Collect (00_StoaSandbox/coin.pact L1804–1827)
    ;; PRE — claimable amount (UrStoa let-binding · URC_URV|ClaimableRewards; includes dust rule):
    ;;   URC_CollectClaimableRewards — inside phase 1 / 5 XIs after FVT phase 0 accrual
    ;; PHASE 0 — FVT two-tier accrual prelude (README §4a; UrStoa ≡ N/A — not in C_URV|Collect):
    ;;   0.1 Ghost TVL lazy sync (farm, this score)         XI_1|SyncFarmGhostTvlForEmployedScores
    ;;   0.2 Tier-2 member settle (README 2a)               XI_2|SettleMemberTier2
    ;;   0.3 Tier-1 accrue pending at current deb (2b)    XI_2|BankUserTier1Pending
    ;; PHASE 1 — Payout custody (coin step 1 · C_Transmit URV|KONTO→account):
    ;;   1.1 Transfer reward DPTF AQP|SC_NAME → patron      XI_TransferRewardDptfFromVault
    ;; PHASE 2 — User row (coin step 2 · XI_URV|ResetPendingRewards):
    ;;   2.1 Zero pending-rewards on RPS|User               WU_RpsUser|PendingRewards
    ;; PHASE 3 — Unclaimed (coin step 3 · XI_URV|UpdateUnclaimedCount false when user-supply=0):
    ;;   3.1 FVT adapt: decrement when deb-score = 0        XI_BookCollectUnclaimed
    ;; PHASE 4 — Checkpoint (coin step 4 · XI_URV|UpdateUserRPS vault current-rps):
    ;;   4.1 FVT adapt: advance last-rps to L_i               WU_RpsUser|LastRps
    ;; PHASE 5 — Global vault (coin step 5 · XI_URV|UpdateVaultSupply available-rewards false):
    ;;   5.1 Decrement available-rewards by payout          WU_RpsGlobal|AvailableRewards
    ;;       (ICO slot after phase 1, before phase 2 — same URC read as UrStoa available-rewards let)
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;;
    ;; ───────────────────────────────────────────────────────────────────────────
    ;; INJECT FUNCTION MATRIX — all three route through the ONE core XI_FvtInjectCore
    ;; ───────────────────────────────────────────────────────────────────────────
    ;;   Entrypoint (Talos wrapper)        Farm(0,LP)  Vault(1,TF/SF/NF)  Treasury(2,OF)  Divisor  Tx
    ;;   C_Inject   (CC_AQP-FVT|Inject)        yes           yes               yes          naive    1
    ;;   CC_Inject  (CC_AQP-FVT|Inject)       yes           yes               yes          fresh    1
    ;;   C_MTX|2|Inject defpact (C_2|Inject)  yes           yes               yes          fresh    2*
    ;;   (* spike fallback for CC_Inject — up to 2×N_FIX stale stakers across 2 steps)
    ;;
    ;;   NAIVE  = distribute over the CURRENT divisor (may be deb-lagged; self-heals at each staker's collect).
    ;;   FRESH  = scan URH_FvtStalePresentUsers + FIX every stale member first (settle@old-deb → refresh SCORE deb
    ;;            → resync), so the distribution reflects LIVE debs and is fair across stakers. HEAVY (R3 `CC_`).
    ;;
    ;;   ALL FVT classes are deb-stale-exposed, so all three serve all classes:
    ;;    · Vault/Treasury: inject divisor = maintained SCR/FVT total-deb-score mirror (stale-able).
    ;;    · Farm: Tier-1 denominator S is fresh (URC_FarmInjectDenominatorFresh), but the Tier-2 per-member
    ;;      L_i-advance divisor is SCR|ScoreTotalDebScore — stale-able for singular / non-true-triplet members
    ;;      (e.g. a mosaic farm carrying a singular score). True-triplet members are deb-independent (lane weights)
    ;;      and the fix no-ops on them.
    ;;   Inject cost scales with MEMBER count (employed score-entities; a triplet = ONE member): a 4-member farm
    ;;   costs one member-iteration more than a 3-member farm.
    ;; ───────────────────────────────────────────────────────────────────────────
    ;;
    (defun CC_InjectStream:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
        @doc "Inject a reward DPTF as a TIME-STREAM — the DELAYED inject path (any FVT class): `amount` vests \
            \ LINEARLY over `duration` seconds (1h..365d) and whoever is staked during each slice earns that slice \
            \ (late stakers included). duration = 0 is not accepted here — use C_Inject for an instant inject. \
            \ Streams are independent + overlap (no merge), capped per the FVT owner konto's Elite tier; a full \
            \ lane accepts only instant injects until a stream finishes. Delegates to XI_FvtAddStream under \
            \ FVT|C>INJECT-STREAM (validate + custody + SECURE). UI: URC_LiveClaimable / URC_StreamStatus show \
            \ real-time accrual. See Audit/STREAMED-INJECT-DESIGN.md."
        (P|UEV_IMC)
        (with-capability (FVT|C>INJECT-STREAM patron fvt-id reward-dptf-id amount duration)
            (XI_FvtAddStream patron fvt-id reward-dptf-id amount duration)
        )
    )
    (defun CC_Inject:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "HEAVY (R3 `CC_`) enforced-FRESH inject for ANY FVT class (farm/vault/treasury) — see the INJECT \
            \ FUNCTION MATRIX above C_Inject. Before injecting, SCAN the FVT's present users (`URH_FvtStalePresentUsers` \
            \ — one select over the purpose-built presence table, populated for every class at stake) and FIX every \
            \ stale member (settle-at-old-deb across all streams → refresh SCORE deb → resync via XI_FixUserFvtDeb), so \
            \ the distribution reflects LIVE debs and is fair to every current staker. Atomic: fixing the whole scanned \
            \ set leaves ZERO stale — NO second scan. Why farms need this too: a farm's Tier-1 denominator S is always \
            \ fresh (URC_FarmInjectDenominatorFresh), BUT its Tier-2 per-member L_i-advance divisor is the maintained \
            \ SCR|ScoreTotalDebScore mirror, which goes deb-stale for singular / non-true-triplet members (e.g. a \
            \ mosaic farm carrying a singular score) exactly like a vault — the fix un-stales it (true-triplet members \
            \ no-op: deb-independent lanes). Same authorization as C_Inject (FVT|C>INJECT). For spike loads that exceed \
            \ one tx, use the MTX|n|C_Inject defpact (MTX-AQP). UrStoa ≡ C_URV|Inject with a pre-fresh divisor."
        (P|UEV_IMC)
        (with-capability (FVT|C>INJECT patron fvt-id reward-dptf-id amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;===>PHASE 0 (CC)=== SCAN the FVT's STALE present users + FIX every stale member (recording
                        ;; the 2e forced-fix count per user) → fresh divisor. Atomic: fixing the whole scanned set ⟹
                        ;; ZERO stale afterward (scan-cut, no re-scan).
                        (let
                            (
                                (members:[string] (URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
                                (reward-rows:[string] (URH_FVT-RG|EnabledRewardRows fvt-id))
                            )
                            ;; DRIP each reward lane once (checkpoint) before the fix loop → users settle at now's index
                            (map (lambda (d:string) (XI_ReleaseStream fvt-id d)) reward-rows)
                            (map (lambda (u:string) (XI_FixUserFvtDebPenalizedIn fvt-id reward-dptf-id u members reward-rows)) (URH_FvtStalePresentUsers fvt-id))
                            (UC_EmptyOc)
                        )
                        ;;===>PHASE 1-3=== inject on the now-FRESH divisor (shared core, also driven by the defpact)
                        (XI_FvtInjectCore patron fvt-id reward-dptf-id amount)
                    ]
                    []
                )
            )
        )
    )
    (defun CCp_InjectFixChunk:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "PAGE the enforced-fresh inject's FIX phase — the scalable prelude to CC_InjectFinalize, the defun+gate \
            \ twin of the fixed 2-step C_MTX|2|Inject defpact, for stale sets exceeding one tx. Fixes up to `chunk` \
            \ CURRENTLY-stale present users (settle at old deb + refresh to live + resync mirror, recording the 2e \
            \ forced-fix count — same penalized fix as the single-tx CC_Inject and the defpact). No cursor: the \
            \ stale set SHRINKS as it is fixed (fixed users read fresh, so they drop out of URH_FvtStalePresentUsers) \
            \ — repeat until none remain, then CC_InjectFinalize. P|UEV_IMC + FVT|C>INJECT-FIX (reward context + chunk \
            \ bound). Between-tx staleness from external Elite-DEB moves is re-caught by the next scan; finalize \
            \ enforces zero-stale at inject."
        (P|UEV_IMC)
        (with-capability (FVT|C>INJECT-FIX patron fvt-id reward-dptf-id chunk)
            (let
                (
                    (stale:[string] (URH_FvtStalePresentUsers fvt-id))
                )
                (let
                    (
                        (batch:[string] (take chunk stale))
                        ;; hoist the FVT-invariant member + reward-row lists ONCE for the whole chunk (no per-user re-scan)
                        (members:[string] (URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
                        (reward-rows:[string] (URH_FVT-RG|EnabledRewardRows fvt-id))
                    )
                    ;; DRIP each reward lane ONCE (checkpoint) before the fix loop so every user settles against the
                    ;; now-current index (no time passes during the batch tx). No-op when no lane carries a stream.
                    (map (lambda (d:string) (XI_ReleaseStream fvt-id d)) reward-rows)
                    ;; force-refresh this chunk of stale stakers (penalized); fixed users drop out of the stale set
                    (map (lambda (u:string) (XI_FixUserFvtDebPenalizedIn fvt-id reward-dptf-id u members reward-rows)) batch)
                    (let
                        (
                            (remaining:integer (- (length stale) (length batch)))
                        )
                        (format "Inject-fix: fixed {} of {} stale staker(s) — {} remain{}." [(length batch) (length stale) remaining (if (= remaining 0) " (ready to CC_InjectFinalize)" ", keep paging")]))
                )
            )
        )
    )
    (defun CC_InjectFinalize:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "FINALIZE a paginated enforced-fresh inject: enforce that NO stale present user remains (the prior \
            \ CCp_InjectFixChunk pages made the divisor live), then inject on the fresh divisor via the shared \
            \ XI_FvtInjectCore — identical outcome to the single-tx CC_Inject and the C_MTX|2|Inject defpact terminal \
            \ step. The zero-stale gate is the enforced-fresh guarantee at the moment of inject (a heavy scan, so it \
            \ lives in the body, not the defcap). P|UEV_IMC + FVT|C>INJECT (same auth as any inject)."
        (P|UEV_IMC)
        (with-capability (FVT|C>INJECT patron fvt-id reward-dptf-id amount)
            ;; enforced-fresh gate: refuse to inject while any present staker is stale (page CCp_InjectFixChunk first).
            ;; The URH_ scan (select) MUST be computed in a let, NOT inside the enforce — Pact evaluates an enforce
            ;; predicate in read-only/sys-only mode, where select is disallowed. Fires before XI_FvtInjectCore's
            ;; custody transfer, so an aborted finalize moves no funds.
            (let
                (
                    (stale-remaining:integer (length (URH_FvtStalePresentUsers fvt-id)))
                )
                (enforce (= 0 stale-remaining)
                    "Stale stakers remain — page CCp_InjectFixChunk until none remain before finalizing (or use single-tx CC_Inject)")
                (XI_FvtInjectCore patron fvt-id reward-dptf-id amount)
            )
        )
    )
    (defun CCp_UnstaleAll:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "OWNER-run mass deb-unstale: force-refresh up to `chunk` CURRENTLY-stale present stakers of `fvt-id` to \
            \ make the entity INJECTION-READY, WITHOUT injecting — the inject's FIX phase (CCp_InjectFixChunk) decoupled \
            \ from the inject. Same penalized fix (XI_FixUserFvtDebPenalizedIn: settle at old deb → refresh to live → \
            \ resync mirror, recording the 2e forced-fix count on this lane, which the user reimburses in IGNIS at his \
            \ next collect), so pre-unstaling tags stale users EXACTLY as a real inject would. No cursor: fixed users \
            \ read fresh and drop out of URH_FvtStalePresentUsers, so the stale set SHRINKS — repeat until none remain, \
            \ then a cheap light C_Inject (or CC_Inject) runs on the fresh divisor. When NO present staker is stale it \
            \ is a cheap no-op reporting `all up to date`. OWNER-GATED (contrast the permissionless inject-fix). \
            \ P|UEV_IMC + FVT|C>UNSTALE-ALL (owner + reward context + chunk bound). Not IGNIS-billed (gas-station \
            \ subsidised like the inject-fix pages; cost is recovered from the fixed users' 2e)."
        (P|UEV_IMC)
        (with-capability (FVT|C>UNSTALE-ALL patron fvt-id reward-dptf-id chunk)
            (let
                (
                    (stale:[string] (URH_FvtStalePresentUsers fvt-id))
                )
                (let
                    (
                        (batch:[string] (take chunk stale))
                        ;; hoist the FVT-invariant member + reward-row lists ONCE for the whole chunk (no per-user re-scan)
                        (members:[string] (URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
                        (reward-rows:[string] (URH_FVT-RG|EnabledRewardRows fvt-id))
                    )
                    ;; DRIP each reward lane ONCE (checkpoint) before the fix loop so every user settles against the
                    ;; now-current index (no time passes during the batch tx). No-op when no lane carries a stream.
                    (map (lambda (d:string) (XI_ReleaseStream fvt-id d)) reward-rows)
                    ;; force-refresh this chunk of stale stakers (penalized — records the 2e forced-fix count); fixed
                    ;; users read fresh and drop out of the stale set.
                    (map (lambda (u:string) (XI_FixUserFvtDebPenalizedIn fvt-id reward-dptf-id u members reward-rows)) batch)
                    (let
                        (
                            (remaining:integer (- (length stale) (length batch)))
                        )
                        (if (= (length stale) 0)
                            (format "Unstale-all: FVT {} lane {} — all present stakers up to date (injection-ready)." [fvt-id reward-dptf-id])
                            (format "Unstale-all: unstaled {} of {} stale staker(s) — {} remain{}." [(length batch) (length stale) remaining (if (= remaining 0) " (injection-ready)" ", keep paging")])))
                )
            )
        )
    )
    (defun CC_SweepRevokeAnchor:string
        (patron:string anchor-id:string)
        @doc "HEAVY (R3 CC_) single-tx RE-SCORE SWEEP that RETIRES an EMPLOYED anchor (H4 half-2). Freezes the \
            \ affected pools, removes the anchor globally (swept-revoke — skips the #9 score-link lock), recomputes \
            \ EVERY present holder on every affected FVT member (settle → aggregate/lane refold → deb refresh → \
            \ mirror), then unfreezes. Owner-initiated: the anchor owner (= the anchored-asset owner) signs; CAP_Owner \
            \ is enforced inside ANK|XE>SWEEP-REVOKE. Scans the boost-class reverse index (ANK::UR_BC|ScoreLinks) × \
            \ each score's present users — bounded by score DEFINITIONS × stakers. For staker sets exceeding one tx, \
            \ use the paginated MTX-AQP::C_MTX|2|SweepRevokeAnchor defpact (mirrors CC_Inject → C_MTX|2|Inject). Lives in \
            \ AQP-FVT (earliest module that can call ANK/SCR/POOL/FVT + owns the recompute). P|UEV_IMC + \
            \ FVT|C>SWEEP-REVOKE. `patron` is retained for symmetry / future IGNIS."
        (P|UEV_IMC)
        (with-capability (FVT|C>SWEEP-REVOKE patron anchor-id)
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    ;;
                    (boost-class-id:string (ref-ANK::UR_ANK|BoostClassId anchor-id))
                    (score-ids:[string] (ref-ANK::UR_BC|ScoreLinks boost-class-id))
                )
                ;; 1. FREEZE every affected pool (stake + collect blocked) — idempotent per shared pool
                (map (lambda (sid:string) (ref-AQP::XE_SetSweepInProgress (ref-SCR::UR_SCR|ScoreAqpoolLink sid) true)) score-ids)
                ;; 2. REVOKE the anchor globally (swept — skips the #9 lock; the recompute below un-stales everyone)
                (ref-ANK::XE_SweepRevokeAnchor anchor-id)
                ;; 3. RECOMPUTE every present holder on every affected member. URH_FvtPresentUsers (ALL present) not
                ;;    the stale subset: right after removal the aggregate is not yet refolded, so no holder reads as
                ;;    deb-stale yet; the per-user recompute no-ops for holders whose aggregate did not change.
                (map
                    (lambda (sid:string)
                        (XI_FvtSweepRecomputeChunk
                            (ref-SCR::UR_SCR|ScoreFvtLink sid)
                            (if (ref-SCR::UR_SCR|ScoreTriplet sid) (ref-SCR::UR_SCR|ScoreTripletId sid) sid)
                            boost-class-id
                            (URH_FvtPresentUsers (ref-SCR::UR_SCR|ScoreFvtLink sid))))
                    score-ids)
                ;; 4. UNFREEZE
                (map (lambda (sid:string) (ref-AQP::XE_SetSweepInProgress (ref-SCR::UR_SCR|ScoreAqpoolLink sid) false)) score-ids)
                (format "Sweep-retired anchor {} (BoostClass {}): recomputed holders across {} employing score(s)." [anchor-id boost-class-id (length score-ids)])
            )
        )
    )
    (defun CC_SweepBegin:string
        (patron:string anchor-id:string)
        @doc "OPEN a paginated defun+gate re-score sweep — the scalable twin of CC_SweepRevokeAnchor (single-tx) \
            \ and C_MTX|2|SweepRevokeAnchor (fixed 2-step defpact). Mirrors steps 1-2 of the single-tx: FREEZE every \
            \ affected pool then swept-revoke the anchor globally (skips the #9 score-link lock), then records the \
            \ frozen recompute-set size in an offset-0 cursor. Recompute is deferred to repeated CCp_SweepRecomputeChunk \
            \ calls under the held freeze; the finalizing chunk unfreezes. Use this + chunking when the holder set \
            \ exceeds one tx; for small sets prefer the single-tx CC_SweepRevokeAnchor. Owner-initiated (the anchor \
            \ owner signs; CAP_Owner enforced inside ANK|XE>SWEEP-REVOKE). P|UEV_IMC + FVT|C>SWEEP-REVOKE."
        (P|UEV_IMC)
        (with-capability (FVT|C>SWEEP-REVOKE patron anchor-id)
            (enforce (not (UR_FVT|SweepActive anchor-id)) "A sweep is already in progress for this anchor")
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    ;;
                    (boost-class-id:string (ref-ANK::UR_ANK|BoostClassId anchor-id))
                )
                (let
                    (
                        (score-ids:[string] (ref-ANK::UR_BC|ScoreLinks boost-class-id))
                    )
                    ;; 1. FREEZE every affected pool (stake + collect blocked) — idempotent per shared pool
                    (map (lambda (sid:string) (ref-AQP::XE_SetSweepInProgress (ref-SCR::UR_SCR|ScoreAqpoolLink sid) true)) score-ids)
                    ;; 2. REVOKE the anchor globally (swept — keeps scores linked; the paged recompute un-stales everyone)
                    (ref-ANK::XE_SweepRevokeAnchor anchor-id)
                    ;; 3. OPEN the cursor at offset 0 over the now-frozen recompute set
                    (let
                        (
                            (total:integer (URC_FvtSweepTotalPresent score-ids))
                        )
                        (WU_FvtSweepProgress anchor-id total 0 true)
                        (format "Sweep begun for anchor {} (BoostClass {}): swept-revoked; {} holder(s) to recompute across {} score(s) — page via CCp_SweepRecomputeChunk." [anchor-id boost-class-id total (length score-ids)]))
                )
            )
        )
    )
    (defun CCp_SweepRecomputeChunk:string
        (patron:string anchor-id:string chunk:integer)
        @doc "PAGE a paginated re-score sweep: recompute the next `chunk` holders over the GLOBAL flattened present \
            \ set [offset, min(offset+chunk, total)), advancing the cursor. When the window reaches `total` the set \
            \ is exhausted, so this chunk also UNFREEZES every affected pool and closes the cursor (completeness is \
            \ ENFORCED — pools cannot unfreeze until offset reaches total). Idempotent recompute funnels through the \
            \ SAME XI_FvtSweepRecomputeChunk as the single-tx and defpact paths. `chunk` is the UI's simulated slice \
            \ size (bounded by the loose SWEEP-CHUNK-MAX backstop). P|UEV_IMC + FVT|C>SWEEP-DRAIN (active-gated)."
        (P|UEV_IMC)
        (with-capability (FVT|C>SWEEP-DRAIN patron anchor-id chunk)
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    ;;
                    (cursor:object{FVT|SweepProgress} (UR_FVT|SweepProgress anchor-id))
                    (boost-class-id:string (ref-ANK::UR_ANK|BoostClassId anchor-id))
                )
                (let
                    (
                        (total:integer (at "total" cursor))
                        (offset:integer (at "offset" cursor))
                        (score-ids:[string] (ref-ANK::UR_BC|ScoreLinks boost-class-id))
                    )
                    (let
                        (
                            (win-hi:integer (if (< (+ offset chunk) total) (+ offset chunk) total))
                        )
                        ;; recompute the window [offset, win-hi) over the frozen global flattened present set
                        (let
                            (
                                (n:integer (XI_FvtSweepRecomputeWindow score-ids boost-class-id offset win-hi))
                            )
                            (if (>= win-hi total)
                                ;; FINAL chunk — recompute set exhausted: unfreeze every affected pool + close the cursor
                                (do
                                    (map (lambda (sid:string) (ref-AQP::XE_SetSweepInProgress (ref-SCR::UR_SCR|ScoreAqpoolLink sid) false)) score-ids)
                                    (WU_FvtSweepProgress anchor-id total total false)
                                    (format "Sweep chunk [{}→{}): recomputed {} holder(s) — set exhausted, anchor {} retired, {} pool(s) unfrozen." [offset win-hi n anchor-id (length score-ids)]))
                                ;; MORE remain — advance the cursor, freeze stays held
                                (do
                                    (WU_FvtSweepProgress anchor-id total win-hi true)
                                    (format "Sweep chunk [{}→{}): recomputed {} holder(s) of {} — {} remain, continue paging." [offset win-hi n total (- total win-hi)]))
                            )
                        )
                    )
                )
            )
        )
    )
    (defun CC_UnstaleMyScores:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-ids:[string])
        @doc "User SELF-SERVICE deb-unstale: the caller refreshes THEIR OWN stale scores across `fvt-ids` — per \
            \ FVT, XI_FixUserFvtDeb settles the caller's pending at the OLD deb, refreshes each score deb to the \
            \ live Elite-DEB, and resyncs the FVT total-deb mirror. NON-penalized (self-service is the cheap path; \
            \ only inject-forced fixes bill the 2e penalty). Each member already fresh (or a true triplet) no-ops, \
            \ so passing a whole FVT only touches its stale members. Single-tx and bounded (a user's own FVT set is \
            \ small — no pagination needed). The UI finds the list via URC_FvtUserHasStaleMember per FVT the user \
            \ stakes. No fund movement (pending is banked, not paid). P|UEV_IMC + FVT|C>UNSTALE-MY-SCORES (owner)."
        (P|UEV_IMC)
        (with-capability (FVT|C>UNSTALE-MY-SCORES patron)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;; fix ALL the caller's stale members across the listed FVTs (each fresh member no-ops)
                        (do
                            (map (lambda (fvt-id:string) (XI_FixUserFvtDeb patron fvt-id)) fvt-ids)
                            (UC_EmptyOc))
                        ;; GAS — the user pays for their own refresh
                        (URCi_UnstaleMyScores patron [(format "{}" [(length fvt-ids)])])
                    ]
                    []
                )
            )
        )
    )
    (defun CC_Collect:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Collect reward DPTF — phases 0 → 5 — see canonical collect map above. UrStoa ≡ C_URV|Collect."
        (P|UEV_IMC)
        (with-capability (FVT|C>COLLECT patron fvt-id score-entity-type score-entity-id reward-dptf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    ;;
                    (pool-id:string
                        (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                        (ref-SCR::UR_SCR|ScoreAqpoolLink (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                        (ref-SCR::UR_SCR|ScoreAqpoolLink score-entity-id)
                    ))
                    (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                ;; DRIP the collected lane FIRST (checkpoint) so the farm pre-settle, the payout
                ;; (URC_CollectClaimableRewards) and the PHASE-4 last-rps advance all reflect streamed rewards
                ;; vested up to `now`. No-op when the lane carries no live stream.
                (XI_ReleaseStream fvt-id reward-dptf-id)
                (if (= (UR_FVT|FvtClass fvt-id) 0)
                    (XI_2|SettleMemberTier2 fvt-id score-entity-type score-entity-id reward-dptf-id)
                    true
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;===>PHASE 0=== (audit LP redesign / Stage 2b) farm ghost-TVL sync REMOVED — L_i is
                        ;; advanced at inject (split-at-inject); the pre-settle above still flushes parked pending.
                        ;;
                        ;;===>PHASE 1=== coin step 1 · C_Transmit URV|KONTO→account
                        ;; PRE payout via URC_CollectClaimableRewards inside XI (post phase 0, pre reset)
                        (XI_TransferRewardDptfFromVault patron pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
                        ;;
                        ;;===>PHASE 5=== coin step 5 · XI_URV|UpdateVaultSupply false
                        ;; ICO slot before phase 2 so URC reads same pre-reset state as UrStoa available-rewards let
                        (let
                            (
                                (payout:decimal
                                    (URC_CollectClaimableRewards patron pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
                                )
                                (ar:decimal (UR_FVT-RG|AvailableRewards fvt-id reward-dptf-id))
                                (new-ar:decimal (- ar payout))
                                ;; #10 Tier-1: decrement the member mini-vault too. Clamp at 0 for the global-sweep
                                ;; case (payout = global available ≥ member available), which zeroes the member vault.
                                (ma:decimal (UR_FVT-MV|AvailableRewards fvt-id score-entity-id reward-dptf-id))
                                (new-ma:decimal (let ((m:decimal (- ma payout))) (if (< m 0.0) 0.0 m)))
                            )
                            ;; SECURE: granted by WU_RpsGlobal|AvailableRewards / WU_MemberVault|AvailableRewards (underlying W_).
                            (WU_RpsGlobal|AvailableRewards fvt-id reward-dptf-id new-ar)
                            (WU_MemberVault|AvailableRewards fvt-id score-entity-id reward-dptf-id new-ma)
                            (UC_EmptyOc)
                        )
                        ;;
                        ;;===>PHASE 2=== coin step 2 · XI_URV|ResetPendingRewards
                        (do
                            ;; SECURE: granted by WU_RpsUser|PendingRewards (underlying W_).
                            (WU_RpsUser|PendingRewards patron fvt-id score-entity-id reward-dptf-id 0.0)
                            (UC_EmptyOc)
                        )
                        ;;
                        ;;===>PHASE 3=== coin step 3 · XI_URV|UpdateUnclaimedCount false
                        (XI_BookCollectUnclaimed patron pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
                        ;;
                        ;;===>PHASE 4=== coin step 4 · XI_URV|UpdateUserRPS (farm: L_i; vault/treasury: G)
                        (do
                            ;; SECURE: granted by WU_RpsUser|LastRps (underlying W_).
                            (WU_RpsUser|LastRps patron fvt-id score-entity-id reward-dptf-id
                                (URC_FvtTier1IndexRps fvt-id score-entity-id reward-dptf-id)
                            )
                            (UC_EmptyOc)
                        )
                        ;;
                        ;;===>PHASE 6=== (M3 #12 deb-staleness collect-backstop) delegate to the SHARED fix
                        ;; XI_FixUserMemberDeb: iff deb-based & stale, settle the patron's pending at OLD deb across
                        ;; ALL reward streams (the just-collected stream re-settles to 0 — its last-rps is already G;
                        ;; the OTHER streams get settled here, closing the multi-reward-dptf edge), refresh the SCORE
                        ;; deb-score(s) to live (each triplet leg at its OWN pool), and resync the FVT total-deb mirror
                        ;; by the member delta. Runs AFTER phases 1-4 so settle-before-weight-change holds. No-op when
                        ;; fresh or a TRUE triplet (deb-independent lanes).
                        (XI_FixUserMemberDeb patron fvt-id score-entity-type score-entity-id)
                        ;;===>PHASE 7=== (M3 #12 2e) inject-forced-fix penalty: `count × RATE` NON-discountable IGNIS,
                        ;; then zero the count. Non-discount via gross-up (price = count×RATE / patron-discount → after
                        ;; the uniform prime-time discount it lands at exactly count×RATE). The reward paid is untouched;
                        ;; self-fixing (PHASE 6) is never penalized, so it stays the cheaper path. No-op when count = 0.
                        (let
                            (
                                (ffc:integer (UR_FVT-FFC|Count fvt-id reward-dptf-id patron))
                            )
                            (if (<= ffc 0)
                                (UC_EmptyOc)
                                (let
                                    (
                                        (ref-DALOS:module{OuronetDalosV1} DALOS)
                                        (penalty:decimal (* (dec ffc) CT_FORCED_FIX_RATE))
                                    )
                                    (WU_FvtForcedFixCount|Zero fvt-id reward-dptf-id patron)
                                    (ref-IGNIS::UDC_ConstructOutputCumulator
                                        (/ penalty (ref-DALOS::URC_IgnisGasDiscount patron)) patron trigger []
                                    )
                                )
                            )
                        )
                        (URCi_Collect fvt-id [fvt-id score-entity-id reward-dptf-id])
                    ]
                    []
                )
            )
        )
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
    ;;   3.1 DPTF anchor refresh                  UrStoa ≡ N/A · TF only (XI_RefreshTrueFungibleStakeAnchors)
    ;;   3.2 DPSF anchor refresh                  UrStoa ≡ N/A · DPDC son=true (incremental nonces + amounts)
    ;;   3.3 DPNF anchor refresh                  UrStoa ≡ N/A · DPDC son=false (incremental nonces)
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
    ;; Flow slots: TF=1.1–1.3,3.1 | OF=1.1–1.2 (1.3/3.x comment-only) | DPDC=1.1–1.2 + 3.2 or 3.3
    ;; ═══════════════════════════════════════════════════════════════════════════
    ;;
    ;; --- TF stake/unstake recipe (Talos client → CC_TrueFungibleStakeFlow) ---
    (defun CC_TrueFungibleStakeFlow:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Core TF stake/unstake recipe. Phases 1 → 2 → 3 → 4 → 5 — see canonical map above."
        (P|UEV_IMC)
        (with-capability (FVT|C>TRUE-FUNGIBLE-STAKE-FLOW pool-id owner-id beneficiary-id dptf-id amount direction)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    ;;
                    (settle-bundle:object{FVT|StakeSettleBundle}
                        (URHC_BuildStakeSettleBundle pool-id beneficiary-id)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;===>PHASE 1===
                        ;; PHASE 1.1 — Custody transfer · UrStoa ≡ X_UR|Transfer
                        (ref-AQP::XE_TrueFungibleTransfer
                            pool-id owner-id beneficiary-id dptf-id amount direction)
                        ;; PHASE 1.2 — Per-pool DPTFTracker · UrStoa ≡ N/A
                        (ref-AQP::XE_TrueFungiblePoolTracker
                            pool-id owner-id beneficiary-id dptf-id amount direction)
                        ;; PHASE 1.3 — BenDptfTotal rollup · UrStoa ≡ N/A
                        (ref-AQP::XE_TrueFungibleBeneficiaryRollup
                            pool-id owner-id beneficiary-id dptf-id amount direction)
                        ;;
                        ;;===>PHASE 2===
                        ;; PHASE 2 — FVT RPS prelude at OLD deb (2.1→2.2→2.3)
                        (XI_RpsPreScore beneficiary-id pool-id settle-bundle)
                        ;;
                        ;;===>PHASE 3===
                        ;; PHASE 3.1 — DPTF anchor refresh · UrStoa ≡ N/A (TF only)
                        (XI_RefreshTrueFungibleStakeAnchors beneficiary-id dptf-id)
                        ;; PHASE 3.2 — DPSF anchor slot · N/A (DPDC son=true)
                        ;; PHASE 3.3 — DPNF anchor slot · N/A (DPDC son=false)
                        ;;
                        ;;===>PHASE 4===
                        ;; PHASE 4 — SCORE vault + user + nzs
                        (ref-SCR::XE_ApplyTrueFungibleStakeDelta
                            pool-id beneficiary-id dptf-id amount direction
                            (ref-AQP::URC_PoolActiveScoreIds pool-id)
                            (ref-AQP::URC_DptfStakeIsNativeLeg dptf-id)
                        )
                        ;; PHASE 4.5 — Sync FVT|T total-deb-score mirror for vault inject denominator
                        (XI_SyncFvtTotalDebMirrors (at "pre-member-debs" settle-bundle))
                        ;; PHASE 4.6 — Re-snapshot farm-triplet Level-1 weights (maintained Σ w-user divisor)
                        (XI_SyncTripletLaneWeights beneficiary-id (at "settle-plans" settle-bundle))
                        ;; PHASE 4.7 — Presence: stake→add, unstake→recompute (flip false on last withdrawal)
                        (XI_SyncFvtPresence beneficiary-id (at "distinct-fvts" settle-bundle) direction)
                        ;;
                        ;;===>PHASE 5===
                        ;; PHASE 5.1 — RPS unclaimed-count · UrStoa ≡ UpdateUnclaimedCount
                        (XI_BookStakeUnclaimedCounts beneficiary-id pool-id settle-bundle)
                        ;; PHASE 5.2 — RPS checkpoint last-rps · UrStoa ≡ UpdateUserRPS
                        (XI_CheckpointStakeRps beneficiary-id pool-id settle-bundle)
                    ]
                    []
                )
            )
        )
    )
    ;;
    ;; --- OF stake/unstake recipe (Talos ×4 → CC_OrtoFungibleStakeFlow) ---
    ;;   No phase 2.2 — ANK anchors are DPTF / DPSF / DPNF only; OF custody does not refresh promile.
    (defun CC_OrtoFungibleStakeFlow:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
        @doc "Core OrtoFungible stake/unstake recipe. Phases 1 → 2 → 3 → 4 → 5 — see canonical map above. \
            \ OF: phase 1.3 and 3.x are N/A (comment-only in ICO list)."
        (P|UEV_IMC)
        (with-capability (FVT|C>ORTO-FUNGIBLE-STAKE-FLOW pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts direction)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    ;;
                    ;; M5: beneficiary-id is authoritative BOTH directions (stake and unstake). The caller supplies
                    ;; the real beneficiary on unstake too, so the exact (owner, beneficiary) tracker row is settled —
                    ;; no self-key derivation (which stranded non-self stakes). Sufficiency is enforced in the cap.
                    (settle-beneficiary:string beneficiary-id)
                    (settle-bundle:object{FVT|StakeSettleBundle}
                        (URHC_BuildStakeSettleBundle pool-id settle-beneficiary)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;===>PHASE 1===
                        ;; PHASE 1.1 — Custody transfer · UrStoa ≡ X_UR|Transfer
                        (ref-AQP::XE_OrtoFungibleTransfer
                            pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts direction)
                        ;; PHASE 1.2 — Per-pool DPOFTracker · UrStoa ≡ N/A
                        (ref-AQP::XE_OrtoFungiblePoolTracker
                            pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts direction)
                        ;; PHASE 1.3 — Beneficiary rollup slot · N/A (OF)
                        ;;
                        ;;===>PHASE 2===
                        ;; PHASE 2 — FVT RPS prelude at OLD deb (2.1→2.2→2.3)
                        (XI_RpsPreScore settle-beneficiary pool-id settle-bundle)
                        ;;
                        ;;===>PHASE 3===
                        ;; PHASE 3.1 — DPTF anchor slot · N/A (OF)
                        ;; PHASE 3.2 — DPSF anchor slot · N/A (DPDC son=true)
                        ;; PHASE 3.3 — DPNF anchor slot · N/A (DPDC son=false)
                        ;;
                        ;;===>PHASE 4===
                        ;; PHASE 4 — SCORE vault + user + nzs
                        (ref-SCR::XE_ApplyOrtoFungibleStakeDelta
                            pool-id settle-beneficiary dpof-id nonces nonce-amounts direction
                            (ref-AQP::URC_PoolActiveScoreIds pool-id)
                        )
                        ;; PHASE 4.5 — Sync FVT|T total-deb-score mirror for vault inject denominator
                        (XI_SyncFvtTotalDebMirrors (at "pre-member-debs" settle-bundle))
                        ;; PHASE 4.6 — Re-snapshot farm-triplet Level-1 weights (maintained Σ w-user divisor)
                        (XI_SyncTripletLaneWeights settle-beneficiary (at "settle-plans" settle-bundle))
                        ;; PHASE 4.7 — Presence: stake→add, unstake→recompute (flip false on last withdrawal)
                        (XI_SyncFvtPresence settle-beneficiary (at "distinct-fvts" settle-bundle) direction)
                        ;;
                        ;;===>PHASE 5===
                        ;; PHASE 5.1 — RPS unclaimed-count · UrStoa ≡ UpdateUnclaimedCount
                        (XI_BookStakeUnclaimedCounts settle-beneficiary pool-id settle-bundle)
                        ;; PHASE 5.2 — RPS checkpoint last-rps · UrStoa ≡ UpdateUserRPS
                        (XI_CheckpointStakeRps settle-beneficiary pool-id settle-bundle)
                    ]
                    []
                )
            )
        )
    )
    ;;
    ;; --- DPDC collectable stake/unstake recipe (Talos ×4 → CC_CollectableStakeFlow; son=true DPSF / false DPNF) ---
    (defun CC_CollectableStakeFlow:object{IgnisCollectorV1.OutputCumulator}
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
        @doc "Core DPDC collectable stake/unstake recipe. Phases 1 → 2 → 3 → 4 → 5 — see canonical map above. \
            \ son=true DPSF (phase 3.2); son=false DPNF (phase 3.3). Phase 1.3 N/A."
        (P|UEV_IMC)
        (with-capability
            (FVT|C>COLLECTABLE-STAKE-FLOW
                pool-id owner-id beneficiary-id collectable-id son nonces nonce-amounts direction
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    ;;
                    ;; M5: beneficiary-id is authoritative BOTH directions (see CC_OrtoFungibleStakeFlow). The caller
                    ;; supplies the real beneficiary on unstake, so the exact (owner, beneficiary) tracker + Ben rollup
                    ;; rows are settled — no self-key derivation. Sufficiency is enforced in the cap.
                    (settle-beneficiary:string beneficiary-id)
                    (settle-bundle:object{FVT|StakeSettleBundle}
                        (URHC_BuildStakeSettleBundle pool-id settle-beneficiary)
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;===>PHASE 1===
                        ;; PHASE 1.1 — Custody transfer · UrStoa ≡ X_UR|Transfer
                        (ref-AQP::XE_CollectableTransfer
                            pool-id owner-id beneficiary-id collectable-id son nonces nonce-amounts direction)
                        ;; PHASE 1.2 — Per-pool DPSF/DPNF tracker · UrStoa ≡ N/A
                        (ref-AQP::XE_CollectablePoolTracker
                            pool-id owner-id beneficiary-id collectable-id son nonces nonce-amounts direction)
                        ;; PHASE 1.3 — BenDpsf* / BenDpnf* cross-pool rollup · UrStoa ≡ N/A
                        (ref-AQP::XE_CollectableBeneficiaryRollup
                            pool-id owner-id beneficiary-id collectable-id son nonces nonce-amounts direction)
                        ;;
                        ;;===>PHASE 2===
                        ;; PHASE 2 — FVT RPS prelude at OLD deb (2.1→2.2→2.3)
                        (XI_RpsPreScore settle-beneficiary pool-id settle-bundle)
                        ;;
                        ;;===>PHASE 3===
                        ;; PHASE 3.1 — DPTF anchor slot · N/A (TF)
                        ;; PHASE 3.2 — DPSF anchor refresh · AQP-ANK::XE_UpdateSemiFungibleUserAnchorValues (son=true)
                        ;; PHASE 3.3 — DPNF anchor refresh · AQP-ANK::XE_UpdateNonFungibleUserAnchorValues (son=false)
                        (XI_RefreshCollectableStakeAnchors
                            settle-beneficiary collectable-id son nonces nonce-amounts direction)
                        ;;
                        ;;===>PHASE 4===
                        ;; PHASE 4 — SCORE vault + user + nzs
                        (ref-SCR::XE_ApplyCollectableStakeDelta
                            pool-id settle-beneficiary collectable-id son nonces nonce-amounts direction
                            (ref-AQP::URC_PoolActiveScoreIds pool-id)
                        )
                        ;; PHASE 4.5 — Sync FVT|T total-deb-score mirror for vault inject denominator
                        (XI_SyncFvtTotalDebMirrors (at "pre-member-debs" settle-bundle))
                        ;; PHASE 4.6 — Re-snapshot farm-triplet Level-1 weights (maintained Σ w-user divisor)
                        (XI_SyncTripletLaneWeights settle-beneficiary (at "settle-plans" settle-bundle))
                        ;; PHASE 4.7 — Presence: stake→add, unstake→recompute (flip false on last withdrawal)
                        (XI_SyncFvtPresence settle-beneficiary (at "distinct-fvts" settle-bundle) direction)
                        ;;
                        ;;===>PHASE 5===
                        ;; PHASE 5.1 — RPS unclaimed-count · UrStoa ≡ UpdateUnclaimedCount
                        (XI_BookStakeUnclaimedCounts settle-beneficiary pool-id settle-bundle)
                        ;; PHASE 5.2 — RPS checkpoint last-rps · UrStoa ≡ UpdateUserRPS
                        (XI_CheckpointStakeRps settle-beneficiary pool-id settle-bundle)
                    ]
                    []
                )
            )
        )
    )

    ;;<=========================================================================>
    ;;{6}  REPL
    ;; [REPL] dry-run helpers (not on the interface)
    ;;
    ;; --- REPL dry-run (GOV|FVT_ADMIN; not on AcquisitionFarmsVaultsTreasuriesV1) ---
    ;; Until C_Issue / C_AddScoreEntity / C_AddRewardLink are implemented.
    (defun REPL_BootstrapVault:string
        (fvt-id:string owner-konto:string score-id:string reward-dptf-id:string)
        @doc "REPL-only: insert class-1 vault + enabled ScoreEntityLink (type 1) + reward-enabled RPS|Global."
        (with-capability (GOV|FVT_ADMIN)
            (let ((ref-SCR:module{AcquisitionScoresV1} AQP-SCORE))
                (with-capability (SECURE)
                    (WI_Fvt fvt-id
                        (UDC_FVT|Schema 1 owner-konto true true "|" 0.0 0.0 0.0 0.0 0 1 1 true CT_MEMBERSHIP_MODE_BAR false CT_SPLIT_MODE_NA fvt-id)
                    )
                    (WI_ScoreEntityLink fvt-id score-id
                        (UDC_FVT|ScoreEntityLink CT_SCORE_ENTITY_SCORE true "|" 0.0 0.0 false 0.0 0.0 STREAM_EPOCH fvt-id score-id)
                    )
                    (WI_RpsGlobal fvt-id reward-dptf-id
                        (UDC_FVT|RPS|Global true 0.0 0.0 0 0.0 false CT_REWARD_KIND_PLAIN BAR 0 STREAM_EPOCH 0.0 0.0 fvt-id reward-dptf-id)
                    )
                    (ref-SCR::XE_CreateFvtLink score-id fvt-id)
                )
                (enforce (= (ref-SCR::UR_SCR|ScoreFvtLink score-id) fvt-id)
                    "REPL_BootstrapVault: SCR fvt-link not set after XE_CreateFvtLink")
            )
        )
        fvt-id
    )
    (defun REPL_BootstrapTreasury:string
        (fvt-id:string owner-konto:string score-id:string reward-dptf-id:string)
        @doc "REPL-only: insert class-2 treasury + enabled ScoreEntityLink (type 1) + reward-enabled RPS|Global."
        (with-capability (GOV|FVT_ADMIN)
            (let ((ref-SCR:module{AcquisitionScoresV1} AQP-SCORE))
                (with-capability (SECURE)
                    (WI_Fvt fvt-id
                        (UDC_FVT|Schema 2 owner-konto true true "|" 0.0 0.0 0.0 0.0 0 1 1 true CT_MEMBERSHIP_MODE_BAR false CT_SPLIT_MODE_NA fvt-id)
                    )
                    (WI_ScoreEntityLink fvt-id score-id
                        (UDC_FVT|ScoreEntityLink CT_SCORE_ENTITY_SCORE true "|" 0.0 0.0 false 0.0 0.0 STREAM_EPOCH fvt-id score-id)
                    )
                    (WI_RpsGlobal fvt-id reward-dptf-id
                        (UDC_FVT|RPS|Global true 0.0 0.0 0 0.0 false CT_REWARD_KIND_PLAIN BAR 0 STREAM_EPOCH 0.0 0.0 fvt-id reward-dptf-id)
                    )
                    (ref-SCR::XE_CreateFvtLink score-id fvt-id)
                )
                (enforce (= (ref-SCR::UR_SCR|ScoreFvtLink score-id) fvt-id)
                    "REPL_BootstrapTreasury: SCR fvt-link not set after XE_CreateFvtLink")
            )
        )
        fvt-id
    )

)

(create-table P|T)
(create-table P|MT)
;;
(create-table FVT|T)                                            ;; Key = <FVT-ID>
(create-table FVT|T|ScoreEntityLink)                            ;; Key = <FVT-ID> | <Score-Entity-ID>
(create-table FVT|T|MultipletFamily)                            ;; Key = <Multiplet-Family-ID>
(create-table FVT|T|RPS|Global)                                 ;; Key = <FVT-ID> | <DPTF-ID>
(create-table FVT|T|RPS|Member)                                 ;; Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
(create-table FVT|T|RPS|User)                                   ;; Key = <User-ID> | <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
(create-table FVT|T|RPS|Stream)                                 ;; Key = <FVT-ID> | <DPTF-ID> | <position 1..49>
(create-table FVT|T|MemberUserWeight)                           ;; Key = <User-ID> | <FVT-ID> | <Score-Entity-ID>
(create-table FVT|T|MemberVault)                                ;; Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
(create-table FVT|T|UserPresence)                               ;; Key = <FVT-ID> | <Ouronet-ID>
(create-table FVT|T|ForcedFixCount)                             ;; Key = <FVT-ID> | <DPTF-ID> | <User-ID>
(create-table FVT|T|DsaOracleConfig)                            ;; Key = FVT|DSA-ORACLE-KEY (single global row)
(create-table FVT|T|AgencyFee)                                  ;; Key = <FVT-ID> | <Score-Entity-ID>
(create-table FVT|T|QualitySplit)                               ;; Key = <FVT-ID> | <DPTF-ID>
(create-table FVT|T|VacateFreeze)                               ;; Key = <FVT-ID>
(create-table FVT|T|SweepProgress)                              ;; Key = <Anchor-ID>