(interface AcquisitionFarmsVaultsTreasuriesV1
    (defun GOV|Demiurgoi ())
    ;;
    ;;  [UCK]
    (defun UCK_ScoreEntityLink:string (fvt-id:string score-entity-id:string))
    (defun UCK_RpsGlobal:string (fvt-id:string dptf-id:string))
    (defun UCK_RpsMember:string (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UCK_RpsUser:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    (defun UCK_MultipletFamily:string (token-0-id:string token-1-id:string token-2-id:string))
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
    (defun UR_FVT|MemberLinkCount:integer (fvt-id:string))
    (defun UR_FVT|Mosaic:bool (fvt-id:string))
    (defun UR_FVT|MembershipMode:string (fvt-id:string))
    (defun UR_FVT|FvtId:string (fvt-id:string))
    ;;
    ;;  [UR] FVT|ScoreEntityLink (FVT|T|ScoreEntityLink)  Key = <FVT-ID> | <Score-Entity-ID>
    (defun UR_FVT-SEL|Enabled:bool (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|ScoreEntityType:integer (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|Swpair:string (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|GhostTvlWeight:decimal (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|FvtId:string (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|ScoreEntityId:string (fvt-id:string score-entity-id:string))
    ;;
    ;;  [UR] FVT|RPS|Member (FVT|T|RPS|Member)  Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
    (defun UR_FVT-RM|LastFarmRpsG:decimal (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RM|MemberDebRps:decimal (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RM|PendingMemberRewards:decimal (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RM|FvtId:string (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RM|ScoreEntityId:string (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RM|DptfId:string (fvt-id:string score-entity-id:string dptf-id:string))
    ;;
    ;;  [UR] FVT|RPS|Global (FVT|T|RPS|Global)  Key = <FVT-ID> | <DPTF-ID>
    (defun UR_FVT-RG|RewardEnabled:bool (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|CurrentRps:decimal (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|AvailableRewards:decimal (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|UnclaimedCount:integer (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|ZombieRewards:decimal (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|Segmentation:bool (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|FvtId:string (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|DptfId:string (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|RewardKind:string (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|MultipletFamilyId:string (fvt-id:string dptf-id:string))
    ;;
    ;;  [UR] FVT|MultipletFamily (FVT|T|MultipletFamily)  Key = <Multiplet-Family-ID>
    (defun UR_FVT-MF|Token0Id:string (multiplet-family-id:string))
    (defun UR_FVT-MF|Token1Id:string (multiplet-family-id:string))
    (defun UR_FVT-MF|Token2Id:string (multiplet-family-id:string))
    (defun UR_FVT-MF|Ats01Id:string (multiplet-family-id:string))
    (defun UR_FVT-MF|Ats12Id:string (multiplet-family-id:string))
    (defun UR_FVT-MF|Rank:integer (multiplet-family-id:string))
    (defun UR_FVT-MF|Active:bool (multiplet-family-id:string))
    (defun UR_FVT-MF|MultipletFamilyId:string (multiplet-family-id:string))
    ;;
    ;;  [UR] FVT|RPS|User (FVT|T|RPS|User)  Key = <User-ID> | <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
    (defun UR_FVT-RU|LastRps:decimal (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RU|PendingRewards:decimal (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RU|UserId:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RU|FvtId:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RU|ScoreEntityId:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RU|DptfId:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    ;;
    (defun C_TrueFungibleStakeFlow:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    )
    (defun C_OrtoFungibleStakeFlow:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
    )
    (defun C_CollectableStakeFlow:object{IgnisCollectorV1.OutputCumulator}
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
    (defun C_Inject:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun CC_Inject:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun URD_FvtStalePresentUsers:[string] (fvt-id:string))
    (defun XE_FvtFixUserChunk:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string reward-dptf-id:string users:[string])
    )
    (defun XE_SweepSyncTripletLaneWeights:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string fvt-id:string score-entity-id:string)
    )
    (defun XE_FvtSweepRecomputeChunk:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string score-entity-id:string swept-boost-class-id:string users:[string])
    )
    (defun XB_FvtInject:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun UR_FVT-FFC|Count:integer (fvt-id:string dptf-id:string user-id:string))
    (defun C_Collect:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
    )
    (defun URDC_BuildStakeSettleBundle:object
        (pool-id:string beneficiary-id:string)
    )
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
    (defcap P|FVT|REMOTE-GOV ()
        @doc "Remote governor for AQP|SC_NAME vault TFT legs (inject/collect). Registered on AQP-POOL P|T as FVT|RemoteAqpGov."
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
            (ref-P|ATSU::P|A_AddIMP mg)
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
        @doc "One distinct FVT row in URD_FVT|SettleFvtRewardBundle."
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
    ;;
    ;;{2}
    (deftable FVT|T:{FVT|Schema})                               ;; Key = <FVT-ID>
    (deftable FVT|T|ScoreEntityLink:{FVT|ScoreEntityLink})      ;; Key = <FVT-ID> | <Score-Entity-ID>
    (deftable FVT|T|MultipletFamily:{FVT|MultipletFamily})      ;; Key = <Multiplet-Family-ID>
    (deftable FVT|T|RPS|Global:{FVT|RPS|Global})                ;; Key = <FVT-ID> | <DPTF-ID>
    (deftable FVT|T|RPS|Member:{FVT|RPS|Member})                ;; Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
    (deftable FVT|T|RPS|User:{FVT|RPS|User})                    ;; Key = <User-ID> | <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
    (deftable FVT|T|MemberUserWeight:{FVT|MemberUserWeight})    ;; Key = <User-ID> | <FVT-ID> | <Score-Entity-ID>
    (deftable FVT|T|MemberVault:{FVT|MemberVault})              ;; Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
    (deftable FVT|T|UserPresence:{FVT|UserPresence})           ;; Key = <FVT-ID> | <Ouronet-ID>
    (deftable FVT|T|ForcedFixCount:{FVT|ForcedFixCount})        ;; Key = <FVT-ID> | <DPTF-ID> | <User-ID>
    ;;{3}
    (defconst CT_FVT_RPS_PREC 48)
    ;; M3 #12 2e — IGNIS charged per inject-forced deb-fix, at the user's next collect (non-discountable). Governance
    ;; param (placeholder); set ≥ the IGNIS cost of self-fixing one score so self-fixing is always cheaper. ~10 IGNIS.
    (defconst CT_FORCED_FIX_RATE:decimal 10.0)
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
    (defconst GAS|ISSUE-FVT                                     1000.0)
    (defconst GAS|ADD-SCORE-ENTITY                              500.0)
    (defconst GAS|ISSUE-MULTIPLET-FAMILY                        500.0)
    (defconst GAS|TOGGLE-SCORE-ENTITY-LINK                      500.0)
    (defconst GAS|SET-MOSAIC                                    500.0)
    (defconst GAS|ADD-REWARD-LINK                               500.0)
    (defconst GAS|TOGGLE-REWARD-LINK                            500.0)
    (defconst GAS|SET-COMMON-DENOMINATOR                        500.0)
    (defconst GAS|INJECT                                        500.0)
    (defconst GAS|COLLECT                                       500.0)
    (defconst CT_REWARD_KIND_PLAIN                              "PLAIN")
    (defconst CT_REWARD_KIND_MULTIPLET_BASE                     "MULTIPLET_BASE")
    (defconst CT_SCORE_ENTITY_SCORE                             1)
    (defconst CT_SCORE_ENTITY_TRIPLET                           3)
    (defconst CT_MEMBERSHIP_MODE_BAR                            "BAR")
    (defconst CT_MEMBERSHIP_MODE_SCORE                          "SCORE")
    (defconst CT_MEMBERSHIP_MODE_TRUE_TRIPLET                   "TRUE-TRIPLET")
    (defconst CT_MEMBERSHIP_MODE_STANDARD_TRIPLET               "STANDARD-TRIPLET")
    ;;
    ;;<==========>
    ;;CAPABILITIES
    ;;{C1}
    (defcap SECURE ()
        true
    )
    ;;{C2}
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
    (defcap FVT|C>COLLECT
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Collect accrued rewards for patron on one score-entity × reward DPTF. Composes P|SECURE-CALLER + P|FVT|REMOTE-GOV."
        @event
        (UEV_CollectContext patron fvt-id score-entity-type score-entity-id reward-dptf-id)
        (compose-capability (P|SECURE-CALLER))
        (compose-capability (P|FVT|REMOTE-GOV))
    )
    (defcap FVT|XE>SWEEP-FIX (fvt-id:string)
        @doc "Forward (MTX-AQP MTX|n|C_Inject defpact): authorize a chunked deb-staleness FIX pass over an FVT's \
            \ stale stakers — NO fund movement (settle + refresh + mirror-resync only). Composes SECURE."
        (compose-capability (SECURE))
    )
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
                (stake-admission-ok:bool (if direction (ref-AQP::URC_PoolStakeAdmissionOk pool-id) true))
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
            ;;--- UrStoa canonical phases (see map above C_TrueFungibleStakeFlow) ---
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
                (stake-admission-ok:bool (if direction (ref-AQP::URC_PoolStakeAdmissionOk pool-id) true))
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
                (stake-admission-ok:bool (if direction (ref-AQP::URC_PoolStakeAdmissionOk pool-id) true))
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
    ;;{C4}
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;{F0}  [UCK] + [UC] + early [UDC]  (constructors before UR with-default-read defaults)
    (defun UCK_ScoreEntityLink:string (fvt-id:string score-entity-id:string)
        @doc "Composite key for FVT|T|ScoreEntityLink: fvt-id | score-entity-id."
        (concat [fvt-id BAR score-entity-id])
    )
    (defun UCK_RpsGlobal:string (fvt-id:string dptf-id:string)
        @doc "Composite key for FVT|T|RPS|Global: fvt-id | dptf-id."
        (concat [fvt-id BAR dptf-id])
    )
    (defun UCK_RpsMember:string (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Composite key for FVT|T|RPS|Member: fvt-id | score-entity-id | dptf-id."
        (concat [fvt-id BAR score-entity-id BAR dptf-id])
    )
    (defun UCK_RpsUser:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Composite key for FVT|T|RPS|User: user-id | fvt-id | score-entity-id | dptf-id."
        (concat [user-id BAR fvt-id BAR score-entity-id BAR dptf-id])
    )
    (defun UCK_MemberUserWeight:string (user-id:string fvt-id:string score-entity-id:string)
        @doc "Composite key for FVT|T|MemberUserWeight: user-id | fvt-id | score-entity-id."
        (concat [user-id BAR fvt-id BAR score-entity-id])
    )
    (defun UCK_UserPresence:string (fvt-id:string ouronet-account:string)
        @doc "Composite key for FVT|T|UserPresence: fvt-id | ouronet-id."
        (concat [fvt-id BAR ouronet-account])
    )
    (defun UCK_ForcedFixCount:string (fvt-id:string dptf-id:string user-id:string)
        @doc "Composite key for FVT|T|ForcedFixCount: fvt-id | dptf-id | user-id."
        (concat [fvt-id BAR dptf-id BAR user-id])
    )
    (defun UCK_MultipletFamily:string (token-0-id:string token-1-id:string token-2-id:string)
        @doc "Composite key for FVT|T|MultipletFamily: F | token-0 | token-1 | token-2."
        (concat ["F" BAR token-0-id BAR token-1-id BAR token-2-id])
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
            (ref-IGNIS::DALOS|EmptyOutputCumulatorV2)
        )
    )
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
        ,"member-link-count"        : member-link-count
        ,"mosaic"                   : mosaic
        ,"membership-mode"          : membership-mode
        ,"fvt-id"                   : fvt-id}
    )
    (defun UDC_FVT|ScoreEntityLink:object{FVT|ScoreEntityLink}
        (
            score-entity-type:integer
            enabled:bool
            swpair:string
            ghost-tvl-weight:decimal
            total-lane-weight:decimal
            fvt-id:string
            score-entity-id:string
        )
        @doc "Core constructor for object{FVT|ScoreEntityLink}."
        {"score-entity-type"        : score-entity-type
        ,"enabled"                  : enabled
        ,"swpair"                   : swpair
        ,"ghost-tvl-weight"         : ghost-tvl-weight
        ,"total-lane-weight"        : total-lane-weight
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
            fvt-id:string
            dptf-id:string
        )
        @doc "Core constructor for object{FVT|RPS|Global}."
        {"reward-enabled"       : reward-enabled
        ,"current-rps"          : current-rps
        ,"available-rewards"    : available-rewards
        ,"unclaimed-count"      : unclaimed-count
        ,"zombie-rewards"       : zombie-rewards
        ,"segmentation"         : segmentation
        ,"reward-kind"          : reward-kind
        ,"multiplet-family-id"    : multiplet-family-id
        ,"fvt-id"               : fvt-id
        ,"dptf-id"              : dptf-id}
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
        @doc "Constructor for object{FVT|SettleFvtRewards} — one URD_FVT|SettleFvtRewardBundle entry."
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
    ;;{FW}  [W]
    ;; Five blocks — one per deftable (table order). Within each block: WI → WW → WU → WU2+ (only when needed).
    ;; WU lists every schema field: defun when used; comment when [.], select key, or mutates via WW_*.
    ;;
    ;; [1] FVT|T  (FVT|Schema)  Key = <FVT-ID>
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
    ;; WU_Fvt|FvtId — select key; WU not needed.
    ;;
    ;; [2] FVT|T|ScoreEntityLink  Key = <FVT-ID> | <Score-Entity-ID>
    (defun WI_ScoreEntityLink:string
        (fvt-id:string score-entity-id:string row:object{FVT|ScoreEntityLink})
        @doc "Insert FVT|T|ScoreEntityLink full row (C_AddScoreEntity admission)."
        (require-capability (SECURE))
        (insert FVT|T|ScoreEntityLink (UCK_ScoreEntityLink fvt-id score-entity-id) row)
    )
    (defun WU_ScoreEntityLink|Enabled:string
        (fvt-id:string score-entity-id:string enabled:bool)
        @doc "Update enabled on FVT|T|ScoreEntityLink."
        (require-capability (SECURE))
        (update FVT|T|ScoreEntityLink (UCK_ScoreEntityLink fvt-id score-entity-id) {"enabled": enabled})
    )
    (defun WU_ScoreEntityLink|GhostTvlWeight:string
        (fvt-id:string score-entity-id:string ghost-tvl-weight:decimal)
        @doc "Update ghost-tvl-weight (W_i) on FVT|T|ScoreEntityLink."
        (require-capability (SECURE))
        (update FVT|T|ScoreEntityLink (UCK_ScoreEntityLink fvt-id score-entity-id) {"ghost-tvl-weight": ghost-tvl-weight})
    )
    (defun WU_ScoreEntityLink|TotalLaneWeight:string
        (fvt-id:string score-entity-id:string total-lane-weight:decimal)
        @doc "Update total-lane-weight (farm-triplet Level-1 divisor Σ w-user) on FVT|T|ScoreEntityLink."
        (require-capability (SECURE))
        (update FVT|T|ScoreEntityLink (UCK_ScoreEntityLink fvt-id score-entity-id) {"total-lane-weight": total-lane-weight})
    )
    ;; FVT|T|MemberUserWeight  Key = <User-ID> | <FVT-ID> | <Score-Entity-ID>
    (defun WW_MemberUserWeight:string
        (user-id:string fvt-id:string score-entity-id:string contrib-weight:decimal)
        @doc "Upsert farm-triplet per-user Level-1 weight snapshot (w-user at last stake/unstake)."
        (require-capability (SECURE))
        (write FVT|T|MemberUserWeight (UCK_MemberUserWeight user-id fvt-id score-entity-id)
            {"contrib-weight"          : contrib-weight
            ,"user-id"                 : user-id
            ,"fvt-id"                  : fvt-id
            ,"score-entity-id"         : score-entity-id})
    )
    ;; FVT|T|MemberVault  Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>  (Tier-1 dust sweep, M1/#10)
    (defun UR_FVT-MV|AvailableRewards:decimal (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Member mini-vault available-rewards (Tier-1 sweep); 0.0 when absent."
        (with-default-read FVT|T|MemberVault (UCK_RpsMember fvt-id score-entity-id dptf-id)
            {"available-rewards": 0.0} {"available-rewards" := ar} ar)
    )
    (defun UR_FVT-MV|UnclaimedCount:integer (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Member mini-vault unclaimed-count (users with a live claim); 0 when absent."
        (with-default-read FVT|T|MemberVault (UCK_RpsMember fvt-id score-entity-id dptf-id)
            {"unclaimed-count": 0} {"unclaimed-count" := uc} uc)
    )
    (defun WU_MemberVault|AvailableRewards:string
        (fvt-id:string score-entity-id:string dptf-id:string available-rewards:decimal)
        @doc "Set member mini-vault available-rewards (upsert; preserves unclaimed-count)."
        (require-capability (SECURE))
        (write FVT|T|MemberVault (UCK_RpsMember fvt-id score-entity-id dptf-id)
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
            (write FVT|T|MemberVault (UCK_RpsMember fvt-id score-entity-id dptf-id)
                {"unclaimed-count"     : (if direction (+ old-uc 1) (if (> old-uc 0) (- old-uc 1) 0))
                ,"available-rewards"   : (UR_FVT-MV|AvailableRewards fvt-id score-entity-id dptf-id)
                ,"fvt-id"              : fvt-id
                ,"score-entity-id"     : score-entity-id
                ,"dptf-id"             : dptf-id})
        )
    )
    ;;
    ;; [2b] FVT|T|UserPresence  Key = <FVT-ID> | <Ouronet-ID>  (M3 #12 / H4 sweep enumeration)
    (defun UR_FVT-UP|IsPresent:bool (fvt-id:string ouronet-account:string)
        @doc "True while this user holds a live position in ≥1 of the FVT's score-entities; false/absent otherwise."
        (with-default-read FVT|T|UserPresence (UCK_UserPresence fvt-id ouronet-account)
            {"is-present": false} {"is-present" := p} p)
    )
    (defun URD_FvtPresentUsers:[string] (fvt-id:string)
        @doc "HEAVY (one `select` over the small purpose-built presence table): all ouronet-ids currently marked \
            \ present in this FVT. Used by the fresh/checked inject + anchor sweeps to enumerate an FVT's users \
            \ without scanning RPS|User. Stale `true` rows are harmless (consumer no-ops on zero-weight)."
        (map (at "ouronet-id")
            (select FVT|T|UserPresence ["ouronet-id"]
                (and? (where "fvt-id" (= fvt-id)) (where "is-present" (= true)))
            )
        )
    )
    (defun WW_UserPresence:string (fvt-id:string ouronet-account:string is-present:bool)
        @doc "Upsert the user's presence flag for this FVT (SECURE). Add-only true on stake; recomputed false on \
            \ the unstake that drops the user's last position."
        (require-capability (SECURE))
        (write FVT|T|UserPresence (UCK_UserPresence fvt-id ouronet-account)
            {"is-present"  : is-present
            ,"fvt-id"      : fvt-id
            ,"ouronet-id"  : ouronet-account})
    )
    ;;
    ;; [2c] FVT|T|ForcedFixCount  Key = <FVT-ID> | <DPTF-ID> | <User-ID>  (M3 #12 2e penalty)
    (defun UR_FVT-FFC|Count:integer (fvt-id:string dptf-id:string user-id:string)
        @doc "Inject-forced deb-fix count on this (fvt, reward lane, user) since the user last collected it; 0 absent."
        (with-default-read FVT|T|ForcedFixCount (UCK_ForcedFixCount fvt-id dptf-id user-id)
            {"count": 0} {"count" := c} c)
    )
    (defun WU_FvtForcedFixCount|Add:string (fvt-id:string dptf-id:string user-id:string n:integer)
        @doc "Add n forced-fixes to (fvt, reward lane, user) — called by the enforced inject when it un-stales the \
            \ user's scores. No-op when n≤0. Upsert (SECURE)."
        (require-capability (SECURE))
        (if (<= n 0)
            "no forced fixes to record"
            (write FVT|T|ForcedFixCount (UCK_ForcedFixCount fvt-id dptf-id user-id)
                {"count"    : (+ (UR_FVT-FFC|Count fvt-id dptf-id user-id) n)
                ,"fvt-id"   : fvt-id
                ,"dptf-id"  : dptf-id
                ,"user-id"  : user-id})
        )
    )
    (defun WU_FvtForcedFixCount|Zero:string (fvt-id:string dptf-id:string user-id:string)
        @doc "Zero the forced-fix count for (fvt, reward lane, user) after the penalty has been charged at collect (SECURE)."
        (require-capability (SECURE))
        (write FVT|T|ForcedFixCount (UCK_ForcedFixCount fvt-id dptf-id user-id)
            {"count"    : 0
            ,"fvt-id"   : fvt-id
            ,"dptf-id"  : dptf-id
            ,"user-id"  : user-id})
    )
    ;;
    ;; [3] FVT|T|MultipletFamily  Key = <Multiplet-Family-ID>
    (defun WI_MultipletFamily:string
        (multiplet-family-id:string row:object{FVT|MultipletFamily})
        @doc "Insert FVT|T|MultipletFamily full row (C_IssueMultipletFamily only)."
        (require-capability (SECURE))
        (insert FVT|T|MultipletFamily multiplet-family-id row)
    )
    ;;
    ;; [4] FVT|T|RPS|Global  Key = <FVT-ID> | <DPTF-ID>
    (defun WI_RpsGlobal:string
        (fvt-id:string dptf-id:string row:object{FVT|RPS|Global})
        @doc "Insert FVT|T|RPS|Global full row (C_AddRewardLink admission)."
        (require-capability (SECURE))
        (insert FVT|T|RPS|Global (UCK_RpsGlobal fvt-id dptf-id) row)
    )
    (defun WU_RpsGlobal|RewardEnabled:string
        (fvt-id:string dptf-id:string reward-enabled:bool)
        @doc "Update reward-enabled on FVT|T|RPS|Global."
        (require-capability (SECURE))
        (update FVT|T|RPS|Global (UCK_RpsGlobal fvt-id dptf-id) {"reward-enabled": reward-enabled})
    )
    (defun WU_RpsGlobal|CurrentRps:string
        (fvt-id:string dptf-id:string current-rps:decimal)
        @doc "Update current-rps (Tier-2 G) on FVT|T|RPS|Global."
        (require-capability (SECURE))
        (update FVT|T|RPS|Global (UCK_RpsGlobal fvt-id dptf-id) {"current-rps": current-rps})
    )
    (defun WU_RpsGlobal|AvailableRewards:string
        (fvt-id:string dptf-id:string available-rewards:decimal)
        @doc "Update available-rewards on FVT|T|RPS|Global."
        (require-capability (SECURE))
        (update FVT|T|RPS|Global (UCK_RpsGlobal fvt-id dptf-id) {"available-rewards": available-rewards})
    )
    (defun WU_RpsGlobal|UnclaimedCount:string
        (fvt-id:string dptf-id:string unclaimed-count:integer)
        @doc "Update unclaimed-count on FVT|T|RPS|Global."
        (require-capability (SECURE))
        (update FVT|T|RPS|Global (UCK_RpsGlobal fvt-id dptf-id) {"unclaimed-count": unclaimed-count})
    )
    (defun WU_RpsGlobal|ZombieRewards:string
        (fvt-id:string dptf-id:string zombie-rewards:decimal)
        @doc "Set zombie-rewards (escrow-on-empty limbo balance) on FVT|T|RPS|Global."
        (require-capability (SECURE))
        (update FVT|T|RPS|Global (UCK_RpsGlobal fvt-id dptf-id) {"zombie-rewards": zombie-rewards})
    )
    ;;
    ;; [5] FVT|T|RPS|Member  Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
    (defun WI_RpsMember:string
        (fvt-id:string score-entity-id:string dptf-id:string row:object{FVT|RPS|Member})
        @doc "Insert FVT|T|RPS|Member full row (phase 2.1 ensure path)."
        (require-capability (SECURE))
        (insert FVT|T|RPS|Member (UCK_RpsMember fvt-id score-entity-id dptf-id) row)
    )
    (defun WW_RpsMember:string
        (fvt-id:string score-entity-id:string dptf-id:string row:object{FVT|RPS|Member})
        @doc "Upsert full FVT|T|RPS|Member row (Tier-2 settle paths)."
        (require-capability (SECURE))
        (write FVT|T|RPS|Member (UCK_RpsMember fvt-id score-entity-id dptf-id) row)
    )
    ;;
    ;; [6] FVT|T|RPS|User  Key = <User-ID> | <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
    (defun WI_RpsUser:string
        (user-id:string fvt-id:string score-entity-id:string dptf-id:string row:object{FVT|RPS|User})
        @doc "Insert FVT|T|RPS|User full row (phase 2.1 ensure path)."
        (require-capability (SECURE))
        (insert FVT|T|RPS|User (UCK_RpsUser user-id fvt-id score-entity-id dptf-id) row)
    )
    (defun WU_RpsUser|LastRps:string
        (user-id:string fvt-id:string score-entity-id:string dptf-id:string last-rps:decimal)
        @doc "Update last-rps on FVT|T|RPS|User."
        (require-capability (SECURE))
        (update FVT|T|RPS|User (UCK_RpsUser user-id fvt-id score-entity-id dptf-id) {"last-rps": last-rps})
    )
    (defun WU_RpsUser|PendingRewards:string
        (user-id:string fvt-id:string score-entity-id:string dptf-id:string pending-rewards:decimal)
        @doc "Update pending-rewards on FVT|T|RPS|User."
        (require-capability (SECURE))
        (update FVT|T|RPS|User (UCK_RpsUser user-id fvt-id score-entity-id dptf-id) {"pending-rewards": pending-rewards})
    )
    ;;
    ;;{F1}  [UR]
    ;; Reads follow schema order: (1) FVT|Schema (2) ScoreEntityLink (3) MultipletFamily (4) RPS|Global (5) RPS|Member (6) RPS|User
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
    (defun UR_FVT|FvtId:string (fvt-id:string)
        @doc "Reads fvt-id field from FVT row."
        (at "fvt-id" (read FVT|T fvt-id ["fvt-id"]))
    )
    ;;
    ;; [2] FVT|T|ScoreEntityLink  Key = <FVT-ID> | <Score-Entity-ID>
    (defun UR_FVT-SEL|ScoreEntityLink:object{FVT|ScoreEntityLink} (fvt-id:string score-entity-id:string)
        @doc "Reads ScoreEntityLink row; absent rows read as disabled with farm sentinels via default object."
        (with-default-read FVT|T|ScoreEntityLink (UCK_ScoreEntityLink fvt-id score-entity-id)
            (UDC_FVT|ScoreEntityLink CT_SCORE_ENTITY_SCORE false BAR 0.0 0.0 fvt-id score-entity-id)
            {"score-entity-type"        := et
            ,"enabled"                  := en
            ,"swpair"                   := sp
            ,"ghost-tvl-weight"         := w
            ,"total-lane-weight"        := tlw
            ,"fvt-id"                   := fid
            ,"score-entity-id"          := seid}
            (UDC_FVT|ScoreEntityLink et en sp w tlw fid seid)
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
    (defun UR_FVT-MUW|ContribWeight:decimal (user-id:string fvt-id:string score-entity-id:string)
        @doc "Reads a farm-triplet user's stored Level-1 weight snapshot; 0.0 when absent."
        (with-default-read FVT|T|MemberUserWeight (UCK_MemberUserWeight user-id fvt-id score-entity-id)
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
    ;; [3] FVT|T|RPS|Global  (FVT|RPS|Global)  Key = <FVT-ID> | <DPTF-ID>
    (defun UR_FVT-RG|RpsGlobal:object{FVT|RPS|Global} (fvt-id:string dptf-id:string)
        @doc "Reads global RPS row for one reward token; absent rows read as disabled with zeroed rps fields."
        (with-default-read FVT|T|RPS|Global (UCK_RpsGlobal fvt-id dptf-id)
            (UDC_FVT|RPS|Global false 0.0 0.0 0 0.0 false CT_REWARD_KIND_PLAIN BAR fvt-id dptf-id)
            {"reward-enabled"       := re
            ,"current-rps"          := cr
            ,"available-rewards"    := ar
            ,"unclaimed-count"      := uc
            ,"zombie-rewards"       := zb
            ,"segmentation"         := seg
            ,"reward-kind"          := rk
            ,"multiplet-family-id"    := tfid
            ,"fvt-id"               := fid
            ,"dptf-id"              := did}
            (UDC_FVT|RPS|Global re cr ar uc zb seg rk tfid fid did)
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
    ;;
    ;; [4] FVT|T|MultipletFamily
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

    ;; [5] FVT|T|RPS|Member
    (defun UR_FVT-RM|RpsMember:object{FVT|RPS|Member} (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads member-score RPS row; absent rows read as zero g_i / L_i / pending-member-rewards."
        (with-default-read FVT|T|RPS|Member (UCK_RpsMember fvt-id score-entity-id dptf-id)
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
    ;; [5] FVT|T|RPS|User  (FVT|RPS|User)  Key = <User-ID> | <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
    (defun UR_FVT-RU|RpsUser:object{FVT|RPS|User}
        (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Reads user RPS row; absent rows read as zero pending and zero last-rps checkpoint."
        (with-default-read FVT|T|RPS|User (UCK_RpsUser user-id fvt-id score-entity-id dptf-id)
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
    (defun URD_FvtEnabledScoreEntityIdsForFvt:[string] (fvt-id:string)
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
    ;;
    ;;{F3}  [URC]
    ;; --- Cap / stake-flow validation (cheap bools; no keys/select) ---
    ;; URD_FvtScoreEntityLinkKeysForFvt ((keys FVT|T|ScoreEntityLink) scan) RETIRED — M2/#11. Its only caller was
    ;; the vault inject-denominator scan, now replaced by the incrementally-maintained total-deb-score mirror.
    (defun URC_FvtHasScoreEntityLinks:bool (fvt-id:string)
        @doc "True when member-link-count > 0 (cheap row read; preferred over keys/select)."
        (> (UR_FVT|MemberLinkCount fvt-id) 0)
    )
    (defun URC_FvtScoreEntityLinkRowExists:bool (fvt-id:string score-entity-id:string)
        @doc "True when FVT|T|ScoreEntityLink row exists (not default-read absent sentinel)."
        (let
            (
                (trial (try false (read FVT|T|ScoreEntityLink (UCK_ScoreEntityLink fvt-id score-entity-id))))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun URC_FvtRpsGlobalRowExists:bool (fvt-id:string dptf-id:string)
        @doc "True when FVT|T|RPS|Global row exists."
        (let
            (
                (trial (try false (read FVT|T|RPS|Global (UCK_RpsGlobal fvt-id dptf-id))))
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
            \ so it must be read at inject. Enumerates members (URD) — inject is an infrequent, bounded operator path."
        (let
            (
                (member-ids:[string] (URD_FvtEnabledScoreEntityIdsForFvt fvt-id))
            )
            (fold (+) 0.0
                (map
                    (lambda (score-entity-id:string)
                        (URC_MemberStakedStoaValue
                            (UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id)
                            score-entity-id
                            (UR_FVT-SEL|Swpair fvt-id score-entity-id)
                        )
                    )
                    member-ids
                )
            )
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
                    (URD_FvtEnabledScoreEntityIdsForFvt fvt-id)
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
        (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Internal: true when FVT|T|RPS|User row exists (UrStoa UR_URV|IzAccount try-read pattern)."
        (let
            (
                (trial (try false (read FVT|T|RPS|User (UCK_RpsUser user-id fvt-id score-entity-id dptf-id))))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun URC_FvtRpsMemberRowExists:bool
        (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Internal: true when FVT|T|RPS|Member row exists."
        (let
            (
                (trial (try false (read FVT|T|RPS|Member (UCK_RpsMember fvt-id score-entity-id dptf-id))))
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
    (defun URDC_BuildInjectScorePlans:[object{FVT|SettleScorePlan}] (fvt-id:string)
        @doc "Enabled ScoreEntityLinks on FVT × enabled reward dptf-ids — ghost TVL lazy-sync scope."
        (let
            (
                (reward-dptf-ids:[string] (URD_FVT-RG|EnabledRewardRows fvt-id))
                (score-entity-ids:[string] (URD_FvtEnabledScoreEntityIdsForFvt fvt-id))
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
    (defun URDC_BuildStakeSettleBundle:object
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
    (defun URC_SettleStakePendingIgnis:decimal (settle-scores:[string] distinct-fvts:[string])
        @doc "Internal: phase 2.1 settle IGNIS from precomputed lists (C_*StakeFlow / URDC_BuildStakeSettleBundle). \
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
            (enforce (> amount 0.0) "Inject amount must be positive")
            (enforce (URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) "Reward link row must exist")
            (enforce (UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id) "Reward token is disabled for inject")
            (ref-DALOS::UEV_EnforceAccountExists patron)
            (ref-DPTF::UEV_id reward-dptf-id)
            (ref-DPTF::UEV_Amount reward-dptf-id amount)
        )
    )
    (defun UEV_CollectContext
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "C_Collect: dispatch by score-entity-type; MULTIPLET_BASE triplet collect requires matching global."
        (let
            (
                (ref-DALOS:module{OuronetDalosV1} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (reward-kind:string (UR_FVT-RG|RewardKind fvt-id reward-dptf-id))
                ;; the score's employing pool (triplet ⇒ silver leg's pool — mirrors C_Collect's resolution)
                (pool-id:string
                    (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                        (ref-SCR::UR_SCR|ScoreAqpoolLink (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                        (ref-SCR::UR_SCR|ScoreAqpoolLink score-entity-id)))
            )
            ;; sweep D3: collect is frozen while a re-score sweep runs on the pool (the aggregate-promile is in
            ;; flux; a mid-sweep collect on an unswept holder would refresh deb against a stale-high aggregate).
            (enforce (not (ref-AQP::UR_AQP|PoolSweepInProgress pool-id))
                "Collect is frozen while a re-score sweep is in progress on this pool")
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
    ;;{F5}  [CAP]  (capabilities above FUNCTIONS — {C1}–{C4})
    ;;{F6}  [A]
    ;;{F7}  [C]
    ;; --- Lifecycle (FVT|T) ---
    (defun C_Issue:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
        @doc "Create a new FVT (Farm | Vault | Treasury). GAS|ISSUE-FVT + smart STOA from patron; returns fvt-id in output."
        (UEV_IMC)
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
                (ref-IGNIS::KDA|C_Collect patron smart-price)
                (XI_IssueFvt fvt-id fvt-class owner-konto common-denominator)
                (ref-IGNIS::UDC_ConstructOutputCumulator GAS|ISSUE-FVT owner-konto trigger [fvt-id])
            )
        )
    )
    ;;Management (FVT|Schema)
    (defun C_RotateOwnership:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string new-owner-konto:string)
        @doc "Transfer FVT owner-konto. Validation in FVT|C>ROTATE-OWNERSHIP-FVT; medium IGNIS on pre-rotate owner."
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-pre-rotate:string (UR_FVT|OwnerKonto fvt-id))
            )
            (with-capability (FVT|C>ROTATE-OWNERSHIP-FVT fvt-id new-owner-konto)
                (XI_RotateOwnership fvt-id new-owner-konto)
            )
            (ref-IGNIS::UDC_MediumCumulator owner-pre-rotate)
        )
    )
    (defun C_Control:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Set can-upgrade and can-change-owner on FVT. Medium IGNIS on owner-konto."
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
            )
            (with-capability (FVT|C>CONTROL-FVT fvt-id new-can-upgrade new-can-change-owner)
                (XI_Control fvt-id new-can-upgrade new-can-change-owner)
            )
            (ref-IGNIS::UDC_MediumCumulator owner-konto)
        )
    )
    (defun C_SetCommonDenominator:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string common-denominator:string)
        @doc "Farm-only: set common-denominator before any ScoreEntityLinks. GAS|SET-COMMON-DENOMINATOR on owner."
        (UEV_IMC)
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
            (ref-IGNIS::UDC_ConstructOutputCumulator GAS|SET-COMMON-DENOMINATOR owner-konto trigger [fvt-id])
        )
    )
    (defun C_SetMosaic:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string mosaic:bool)
        @doc "Toggle mosaic membership policy when FVT has no ScoreEntityLink rows. GAS|SET-MOSAIC on owner."
        (UEV_IMC)
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
            (ref-IGNIS::UDC_ConstructOutputCumulator GAS|SET-MOSAIC owner-konto trigger [fvt-id])
        )
    )
    ;; --- Score membership (FVT|T|ScoreEntityLink) ---
    (defun C_AddScoreEntity:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "Register score (type 1) or triplet (type 3) on FVT; insert ScoreEntityLink; SCR fvt-links. GAS|ADD-SCORE-ENTITY."
        (UEV_IMC)
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
            (ref-IGNIS::UDC_ConstructOutputCumulator GAS|ADD-SCORE-ENTITY owner-konto trigger [fvt-id score-entity-id])
        )
    )
    (defun C_ToggleScoreEntityLink:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
        @doc "Turn ScoreEntityLink.enabled on/off; farm adjusts S when toggling. GAS|TOGGLE-SCORE-ENTITY-LINK."
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                (owner-konto:string (UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>TOGGLE-SCORE-ENTITY-LINK fvt-id score-entity-type score-entity-id enabled)
                (XI_ToggleScoreEntityLink fvt-id score-entity-id enabled)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator GAS|TOGGLE-SCORE-ENTITY-LINK owner-konto trigger [fvt-id score-entity-id])
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
        (UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV1} IGNIS)
                ;;
                (family-id:string (UCK_MultipletFamily token-0-id token-1-id token-2-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>ISSUE-MULTIPLET-FAMILY token-0-id token-1-id token-2-id ats-0-1-id ats-1-2-id)
                (XI_IssueMultipletFamily token-0-id token-1-id token-2-id ats-0-1-id ats-1-2-id)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator GAS|ISSUE-MULTIPLET-FAMILY patron trigger [family-id])
        )
    )
    ;; --- Reward token registration (FVT|T|RPS|Global) — atomic one row per reward DPTF ---
    (defun C_AddRewardLink:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
        @doc "Register one reward DPTF on FVT (single RPS|Global row). multiplet-family-id BAR for plain tokens (VESTA, etc.); \
            \ F|t0|t1|t2 when reward-dptf-id is family token-0 — enables triplet lane collect on triplet anchors; score anchors stay plain. \
            \ One inject feeds all membership tranches; collect branches on anchor-id (score vs triplet)."
        (UEV_IMC)
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
            (ref-IGNIS::UDC_ConstructOutputCumulator GAS|ADD-REWARD-LINK owner-konto trigger [fvt-id reward-dptf-id multiplet-family-id])
        )
    )
    (defun C_ToggleRewardLink:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Toggle reward-enabled; ±1 enabled-reward-count on flip. GAS|TOGGLE-REWARD-LINK on owner."
        (UEV_IMC)
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
            (ref-IGNIS::UDC_ConstructOutputCumulator GAS|TOGGLE-REWARD-LINK owner-konto trigger [fvt-id reward-dptf-id])
        )
    )
    ;;RPS economics (FVT|T|RPS|Global / FVT|T|RPS|User)
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
    ;;   C_Inject   (AQP-FVT|C_Inject)        yes           yes               yes          naive    1
    ;;   CC_Inject  (AQP-FVT|CC_Inject)       yes           yes               yes          fresh    1
    ;;   MTX|2|C_Inject defpact (C_2|Inject)  yes           yes               yes          fresh    2*
    ;;   (* spike fallback for CC_Inject — up to 2×N_FIX stale stakers across 2 steps)
    ;;
    ;;   NAIVE  = distribute over the CURRENT divisor (may be deb-lagged; self-heals at each staker's collect).
    ;;   FRESH  = scan URD_FvtStalePresentUsers + FIX every stale member first (settle@old-deb → refresh SCORE deb
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
    (defun C_Inject:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "Inject reward DPTF — the NAIVE path (any FVT class): distributes over the CURRENT divisor (may be \
            \ deb-lagged; each staker self-heals at their next collect). See the INJECT FUNCTION MATRIX above. This \
            \ is the C_ client contract (Talos/gas) only — it delegates to the shared XB_FvtInject (UEV_IMC + \
            \ FVT|C>INJECT + XI_FvtInjectCore), the SAME both-internal-and-external entry the MTX|n|C_Inject defpact \
            \ uses. For an enforced-FRESH divisor (fix every stale member first) use CC_Inject or the defpact. \
            \ UrStoa ≡ C_URV|Inject."
        (XB_FvtInject patron fvt-id reward-dptf-id amount)
    )
    (defun CC_Inject:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "HEAVY (R3 `CC_`) enforced-FRESH inject for ANY FVT class (farm/vault/treasury) — see the INJECT \
            \ FUNCTION MATRIX above C_Inject. Before injecting, SCAN the FVT's present users (`URD_FvtStalePresentUsers` \
            \ — one select over the purpose-built presence table, populated for every class at stake) and FIX every \
            \ stale member (settle-at-old-deb across all streams → refresh SCORE deb → resync via XI_FixUserFvtDeb), so \
            \ the distribution reflects LIVE debs and is fair to every current staker. Atomic: fixing the whole scanned \
            \ set leaves ZERO stale — NO second scan. Why farms need this too: a farm's Tier-1 denominator S is always \
            \ fresh (URC_FarmInjectDenominatorFresh), BUT its Tier-2 per-member L_i-advance divisor is the maintained \
            \ SCR|ScoreTotalDebScore mirror, which goes deb-stale for singular / non-true-triplet members (e.g. a \
            \ mosaic farm carrying a singular score) exactly like a vault — the fix un-stales it (true-triplet members \
            \ no-op: deb-independent lanes). Same authorization as C_Inject (FVT|C>INJECT). For spike loads that exceed \
            \ one tx, use the MTX|n|C_Inject defpact (MTX-AQP). UrStoa ≡ C_URV|Inject with a pre-fresh divisor."
        (UEV_IMC)
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
                        (do
                            (map (lambda (u:string) (XI_FixUserFvtDebPenalized fvt-id reward-dptf-id u)) (URD_FvtStalePresentUsers fvt-id))
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
    (defun C_Collect:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Collect reward DPTF — phases 0 → 5 — see canonical collect map above. UrStoa ≡ C_URV|Collect."
        (UEV_IMC)
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
                        (ref-IGNIS::UDC_ConstructOutputCumulator
                            GAS|COLLECT owner-konto trigger [fvt-id score-entity-id reward-dptf-id]
                        )
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
                        (URDC_BuildStakeSettleBundle pool-id beneficiary-id)
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
    ;; --- OF stake/unstake recipe (Talos ×4 → C_OrtoFungibleStakeFlow) ---
    ;;   No phase 2.2 — ANK anchors are DPTF / DPSF / DPNF only; OF custody does not refresh promile.
    (defun C_OrtoFungibleStakeFlow:object{IgnisCollectorV1.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
        @doc "Core OrtoFungible stake/unstake recipe. Phases 1 → 2 → 3 → 4 → 5 — see canonical map above. \
            \ OF: phase 1.3 and 3.x are N/A (comment-only in ICO list)."
        (UEV_IMC)
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
                        (URDC_BuildStakeSettleBundle pool-id settle-beneficiary)
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
    ;; --- DPDC collectable stake/unstake recipe (Talos ×4 → C_CollectableStakeFlow; son=true DPSF / false DPNF) ---
    (defun C_CollectableStakeFlow:object{IgnisCollectorV1.OutputCumulator}
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
        (UEV_IMC)
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
                    ;; M5: beneficiary-id is authoritative BOTH directions (see C_OrtoFungibleStakeFlow). The caller
                    ;; supplies the real beneficiary on unstake, so the exact (owner, beneficiary) tracker + Ben rollup
                    ;; rows are settled — no self-key derivation. Sufficiency is enforced in the cap.
                    (settle-beneficiary:string beneficiary-id)
                    (settle-bundle:object{FVT|StakeSettleBundle}
                        (URDC_BuildStakeSettleBundle pool-id settle-beneficiary)
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
    ;;  FVT lazy-sync on reward entry (C_AddScoreEntity, C_Inject, XI_SettleStakePendingRewards phase-2 entry, C_Collect):
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
    ;;   C_Collect — phased recipe (see canonical collect map above C_Collect)
    ;;
    (defun XI_IssueFvt:string
        (fvt-id:string fvt-class:integer owner-konto:string common-denominator:string)
        @doc "Under SECURE (FVT|C>ISSUE-FVT): insert FVT|T row with zeroed aggregates and enabled-reward-count 0."
        ;; SECURE: granted by WI_Fvt (underlying W_).
        (WI_Fvt fvt-id
            (UDC_FVT|Schema
                fvt-class owner-konto true true common-denominator
                0.0 0.0 0.0 0.0 0 0 0 true CT_MEMBERSHIP_MODE_BAR fvt-id
            )
        )
    )
    (defun XI_SetMosaic:string
        (fvt-id:string mosaic:bool)
        @doc "Under SECURE (FVT|C>SET-MOSAIC): update mosaic; reset membership-mode to BAR."
        (WU2_Fvt|MosaicPolicy fvt-id mosaic CT_MEMBERSHIP_MODE_BAR)
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
                (UDC_FVT|ScoreEntityLink score-entity-type true swpair ghost-weight 0.0 fvt-id score-entity-id)
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
                (family-id:string (UCK_MultipletFamily token-0-id token-1-id token-2-id))
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
            (UDC_FVT|RPS|Global true 0.0 0.0 0 0.0 segmentation reward-kind multiplet-family-id fvt-id reward-dptf-id)
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
    ;;   C_Collect — phased recipe in C_ body (same structure as C_Inject / C_TrueFungibleStakeFlow)
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
            (XI_1|SyncFarmGhostTvlForEmployedScores (URDC_BuildInjectScorePlans fvt-id))
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
    ;; --- Block A · Phase 2.1 settle (C_TrueFungibleStakeFlow) ---
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
            \ Caller builds plans once with reward-dptf-ids from a single URD_FVT|SettleFvtRewardBundle — no URD in child XI. \
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
    (defun XI_1|FarmSplitInject:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string reward-dptf-id:string amount:decimal S:decimal)
        @doc "Split-at-inject (audit LP redesign / Stage 2): distribute <amount> across enabled FARM members by \
            \ their FRESH staked STOA value (member-slice = amount x W_i / S), advancing each member's Tier-1 \
            \ index L_i (member-deb-rps) by member-slice / total-deb — or parking in pending-member-rewards when \
            \ the member has value but no stakers (total-deb = 0). No global G: farms distribute at inject, not \
            \ via a Tier-2 accumulator. Mirrors XI_2|SettleMemberTier2's row math with member-slice in place of earned."
        ;; SECURE: granted by WI_RpsMember / WW_RpsMember (underlying W_).
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV1} DPTF)
                (member-ids:[string] (URD_FvtEnabledScoreEntityIdsForFvt fvt-id))
                (reward-prec:integer (ref-DPTF::UR_Decimals reward-dptf-id))
            )
            (map
                (lambda (score-entity-id:string)
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
                                (w-i:decimal (URC_MemberStakedStoaValue score-entity-type score-entity-id swpair))
                                (member-slice:decimal (floor (/ (* amount w-i) S) reward-prec))
                                (total-deb:decimal (URC_ScoreEntityMemberTier2Divisor fvt-id score-entity-type score-entity-id))
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
                                        (+ L-i-work (floor (/ member-slice total-deb) CT_FVT_RPS_PREC))
                                        L-i-work
                                    )
                                )
                                (new-ptr:decimal
                                    (if (and (= total-deb 0.0) (> member-slice 0.0))
                                        (floor (+ ptr-work member-slice) reward-prec)
                                        ptr-work
                                    )
                                )
                            )
                            (WW_RpsMember fvt-id score-entity-id reward-dptf-id
                                (UDC_FVT|RPS|Member g-i new-li new-ptr fvt-id score-entity-id reward-dptf-id)
                            )
                            ;; #10 credit: this member's routed slice enters its mini-vault (Tier-1 dust sweep)
                            (WU_MemberVault|AvailableRewards fvt-id score-entity-id reward-dptf-id
                                (+ (UR_FVT-MV|AvailableRewards fvt-id score-entity-id reward-dptf-id) member-slice)
                            )
                        )
                    )
                )
                member-ids
            )
            (UC_EmptyOc)
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
    (defun URC_FvtUserHasStaleMember:bool (fvt-id:string user-id:string)
        @doc "True iff the user has ≥1 deb-stale member in the FVT. HEAVY (folds over the FVT's enabled members)."
        (fold (or) false
            (map
                (lambda (m:string) (URC_FvtMemberDebNeedsFix fvt-id user-id (UR_FVT-SEL|ScoreEntityType fvt-id m) m))
                (URD_FvtEnabledScoreEntityIdsForFvt fvt-id)))
    )
    (defun URC_FvtUserStaleMemberCount:integer (fvt-id:string user-id:string)
        @doc "Count of the user's deb-stale members in the FVT = the number of fixes an enforced inject will force \
            \ for this user (the 2e forced-fix increment). HEAVY (folds over the FVT's enabled members)."
        (fold (+) 0
            (map
                (lambda (m:string) (if (URC_FvtMemberDebNeedsFix fvt-id user-id (UR_FVT-SEL|ScoreEntityType fvt-id m) m) 1 0))
                (URD_FvtEnabledScoreEntityIdsForFvt fvt-id)))
    )
    (defun URD_FvtStalePresentUsers:[string] (fvt-id:string)
        @doc "HEAVY sweep scan (M3 #12): the FVT's present users who have ≥1 deb-stale member — the exact set that \
            \ CC_Inject / the MTX|n|C_Inject defpact must fix before injecting. Filters URD_FvtPresentUsers by \
            \ URC_FvtUserHasStaleMember. `take N` of this list gives a defpact step's fix chunk."
        (filter (lambda (u:string) (URC_FvtUserHasStaleMember fvt-id u)) (URD_FvtPresentUsers fvt-id))
    )
    ;; --- Shared deb-staleness FIX (M3 #12 — used by CC_Inject AND collect PHASE 6 backstop) ---
    (defun XI_FixUserMemberDeb:object{IgnisCollectorV1.OutputCumulator}
        (user-id:string fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "FIX one (user, member): iff the member is deb-based (singular or NON-true triplet) AND stale for this \
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
                        (URD_FVT-RG|EnabledRewardRows fvt-id))
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
        @doc "Re-score sweep per-holder recompute for one (user, member) after an anchor in `swept-boost-class-id` \
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
                (URD_FVT-RG|EnabledRewardRows fvt-id))
            (if triplet-true
                ;; TRUE triplet: deb-independent — refold the Level-1 lane weights at the live promile
                (XI_SyncTripletLaneWeights user-id
                    [(UDC_FVT|SettleScorePlan score-entity-type score-entity-id fvt-id [])])
                ;; deb-based (singular / NON-true triplet): refold aggregate → refresh deb → resync mirror
                (let
                    (
                        (pre-member-debs:[object{FVT|MemberPreDeb}]
                            [ {"fvt-id"            : fvt-id
                              ,"score-entity-type" : score-entity-type
                              ,"score-entity-id"   : score-entity-id
                              ,"pre-deb"           : (URC_ScoreEntityMemberDebWeight score-entity-type score-entity-id)} ])
                    )
                    ;; 2. refold the holder's aggregate-promile for the swept class (the DEEPER recompute)
                    (ref-ANK::XE_RecomputeUserBoostAggregates user-id [swept-boost-class-id])
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
    (defun XI_FixUserFvtDeb:object{IgnisCollectorV1.OutputCumulator}
        (user-id:string fvt-id:string)
        @doc "Fix ALL of a user's stale deb-based members in the FVT — one XI_FixUserMemberDeb per enabled member \
            \ (each no-ops internally when fresh or a true triplet). Enumerates the FVT's members (bounded)."
        (require-capability (SECURE))
        (map
            (lambda (member-id:string)
                (XI_FixUserMemberDeb user-id fvt-id (UR_FVT-SEL|ScoreEntityType fvt-id member-id) member-id))
            (URD_FvtEnabledScoreEntityIdsForFvt fvt-id))
        (UC_EmptyOc)
    )
    (defun XI_FixUserFvtDebPenalized:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string reward-dptf-id:string user-id:string)
        @doc "ENFORCED-INJECT variant: fix ALL the user's stale members (XI_FixUserFvtDeb) AND record the 2e \
            \ forced-fix count on (fvt, reward-dptf, user) = how many members were stale (counted BEFORE the fix). \
            \ The user pays that × RATE non-discountable IGNIS at his next collect of this lane. Self-fixing at \
            \ collect (PHASE 6) uses plain XI_FixUserFvtDeb and is NOT penalized. require SECURE."
        (require-capability (SECURE))
        (let
            (
                (n:integer (URC_FvtUserStaleMemberCount fvt-id user-id))
            )
            (XI_FixUserFvtDeb user-id fvt-id)
            (WU_FvtForcedFixCount|Add fvt-id reward-dptf-id user-id n)
            (UC_EmptyOc)
        )
    )
    ;; --- Shared inject-CORE + cross-module XE_ building blocks (CC_Inject FVT-local; MTX|n|C_Inject via MTX-AQP) ---
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
                    ;;===>PHASE 1=== custody transfer · UrStoa ≡ C_Transfer / C_Transmit
                    (ref-TFT::C_Transfer reward-dptf-id patron AQP|SC_NAME amount true)
                    ;;===>PHASE 2+3=== escrow-aware distribute + available-rewards. Reward tokens are ALREADY in
                    ;; custody. ESCROW-on-empty: divisor 0 (no stakers) ⟹ HOLD `amount` as zombie-rewards and touch
                    ;; nothing else — available-rewards is NOT bumped, so the M1 last-claimant dust sweep can never
                    ;; pay this limbo balance to a prior cohort. Otherwise FLUSH R_eff = amount + zombie to whoever is
                    ;; staked NOW (FARM: split-at-inject over fresh S; VAULT/TREASURY: G += R_eff / deb-sum),
                    ;; available-rewards += R_eff, zombie→0. Divisor computed HERE (farm S needs a member scan that
                    ;; cannot live in a defcap; vault deb-sum is the maintained mirror).
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
                                (if (= (UR_FVT|FvtClass fvt-id) 0)
                                    (XI_1|FarmSplitInject fvt-id reward-dptf-id eff denominator)
                                    (WU_RpsGlobal|CurrentRps fvt-id reward-dptf-id
                                        (+ (UR_FVT-RG|CurrentRps fvt-id reward-dptf-id)
                                           (UC_ComputeInjectGainedRps eff denominator)))
                                )
                                ;; available-rewards enters G only NOW (the flush) — bump by the full R_eff.
                                (WU_RpsGlobal|AvailableRewards fvt-id reward-dptf-id
                                    (+ (UR_FVT-RG|AvailableRewards fvt-id reward-dptf-id) eff))
                                ;; zombie fully consumed by this flush (skip the write when there was none).
                                (if (> zombie 0.0)
                                    (WU_RpsGlobal|ZombieRewards fvt-id reward-dptf-id 0.0)
                                    "no escrow to clear")
                            )
                            ;; ESCROW — no stakers (divisor 0): park `amount` in limbo, available-rewards untouched.
                            (WU_RpsGlobal|ZombieRewards fvt-id reward-dptf-id (+ zombie amount))
                        )
                        (UC_EmptyOc)
                    )
                    ;; PHASE 4.1 — Do not reset unclaimed-count · UrStoa comment-only slot
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        GAS|INJECT owner-konto trigger [fvt-id reward-dptf-id (format "{}" [amount])]
                    )
                ]
                []
            )
        )
    )
    (defun XE_FvtFixUserChunk:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string reward-dptf-id:string users:[string])
        @doc "Forward (MTX-AQP defpact step): FIX a chunk of stale stakers in the FVT (settle + refresh + \
            \ mirror-resync per user; each fresh member no-ops), recording the 2e forced-fix count per user on \
            \ `reward-dptf-id` (the injected lane). NO fund movement. Caller passes `take N` of \
            \ URD_FvtStalePresentUsers. UEV_IMC + FVT|XE>SWEEP-FIX (composes SECURE)."
        (UEV_IMC)
        (with-capability (FVT|XE>SWEEP-FIX fvt-id)
            (map (lambda (u:string) (XI_FixUserFvtDebPenalized fvt-id reward-dptf-id u)) users)
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
            \ sweep defpact bills IGNIS. UEV_IMC + FVT|XE>SWEEP-FIX (composes SECURE)."
        (UEV_IMC)
        (with-capability (FVT|XE>SWEEP-FIX fvt-id)
            (XI_SyncTripletLaneWeights beneficiary-id
                [(UDC_FVT|SettleScorePlan (UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id) score-entity-id fvt-id [])])
            (UC_EmptyOc)
        )
    )
    (defun XE_FvtSweepRecomputeChunk:object{IgnisCollectorV1.OutputCumulator}
        (fvt-id:string score-entity-id:string swept-boost-class-id:string users:[string])
        @doc "Forward (re-score sweep defpact): recompute a CHUNK of holders on one (fvt, member) after the swept \
            \ anchor's global removal — per user runs XI_SweepRecomputeUserMember (settle → aggregate refold → deb \
            \ refresh + mirror, or true-triplet lane refold). NO fund movement, NO 2e penalty (owner sweep, D4). \
            \ Caller passes `take N` of the member's present users. UEV_IMC + FVT|XE>SWEEP-FIX (composes SECURE)."
        (UEV_IMC)
        (with-capability (FVT|XE>SWEEP-FIX fvt-id)
            (map
                (lambda (u:string)
                    (XI_SweepRecomputeUserMember u fvt-id (UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id) score-entity-id swept-boost-class-id))
                users)
            (UC_EmptyOc)
        )
    )
    (defun XB_FvtInject:object{IgnisCollectorV1.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "THE single authorized inject entry — usable BOTH internally (C_Inject delegates here) and externally \
            \ (the MTX|n|C_Inject defpact terminal step calls it cross-module), hence `XB`. Just the auth wrapper: \
            \ UEV_IMC + FVT|C>INJECT (validates + composes SECURE) around the one XI_FvtInjectCore. Any FVT class \
            \ (farm/vault/treasury); the core branches on class. Distributes over the CURRENT divisor — enforced- \
            \ fresh callers (CC_Inject / the defpact) fix stale members BEFORE calling. Replaces the former \
            \ XE_FvtInject: after the class-guard removal (N2) it was byte-identical to C_Inject's body, so the two \
            \ collapsed onto this one XB entry."
        (UEV_IMC)
        (with-capability (FVT|C>INJECT patron fvt-id reward-dptf-id amount)
            (XI_FvtInjectCore patron fvt-id reward-dptf-id amount)
        )
    )
    ;;
    ;; --- Block B · Phase 3 anchor refresh (C_TrueFungibleStakeFlow · 3.1) ---
    ;;   XI_RefreshTrueFungibleStakeAnchors
    ;;     ├ AQP-ANK::XE_UpdateTrueFungibleUserAnchorValues
    ;;     └ AQP-POOL::XB_SetBenDptfAnkSyncCount
    ;;
    ;; --- Anchors (AQP-ANK · TF stake only) ---
    (defun XI_RefreshTrueFungibleStakeAnchors:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
        @doc "Internal (C_TrueFungibleStakeFlow phase 3.1 · depth 0]): read post-ico1 BenDptfTotal balance, \
            \ call backward ANK promile refresh + AQP last-ank-sync-count bump; concat IGNIS OCs. \
            \ require-capability (SECURE) only — backward XE_* use UEV_IMC / domain caps."
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
    ;; --- Block B′ · Phase 3 anchor refresh (C_CollectableStakeFlow · 3.2 or 3.3 via son) ---
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
        @doc "Internal (C_CollectableStakeFlow phase 3]): ANK promile refresh — DPSF (son=true) or DPNF (son=false)."
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
            \ settle-bundle from URDC_BuildStakeSettleBundle (same scope as phase 2.1; no second URD). \
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
    ;;
    ;; --- XE forwarders (AQP-VCT TF vacate composes stake/RPS primitives via IMC) ---
    (defun XE_BankScorePendingRewards:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string plan:object)
        (UEV_IMC)
        (with-capability (SECURE)
            (do
                (XI_1|BankScorePendingRewards beneficiary-id pool-id plan)
                (UC_EmptyOc)
            )
        )
    )
    (defun XE_RefreshTrueFungibleStakeAnchors:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
        (UEV_IMC)
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
        (UEV_IMC)
        (with-capability (SECURE)
            (XI_RefreshCollectableStakeAnchors
                beneficiary-id collectable-id son nonces nonce-amounts direction
            )
        )
    )
    (defun XE_BookStakeUnclaimedCounts:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object)
        (UEV_IMC)
        (with-capability (SECURE)
            (XI_BookStakeUnclaimedCounts beneficiary-id pool-id settle-bundle)
        )
    )
    (defun XE_CheckpointStakeRps:object{IgnisCollectorV1.OutputCumulator}
        (beneficiary-id:string pool-id:string settle-bundle:object)
        (UEV_IMC)
        (with-capability (SECURE)
            (XI_CheckpointStakeRps beneficiary-id pool-id settle-bundle)
        )
    )
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
                        (UDC_FVT|Schema 1 owner-konto true true "|" 0.0 0.0 0.0 0.0 0 1 1 true CT_MEMBERSHIP_MODE_BAR fvt-id)
                    )
                    (WI_ScoreEntityLink fvt-id score-id
                        (UDC_FVT|ScoreEntityLink CT_SCORE_ENTITY_SCORE true "|" 0.0 0.0 fvt-id score-id)
                    )
                    (WI_RpsGlobal fvt-id reward-dptf-id
                        (UDC_FVT|RPS|Global true 0.0 0.0 0 0.0 false CT_REWARD_KIND_PLAIN BAR fvt-id reward-dptf-id)
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
                        (UDC_FVT|Schema 2 owner-konto true true "|" 0.0 0.0 0.0 0.0 0 1 1 true CT_MEMBERSHIP_MODE_BAR fvt-id)
                    )
                    (WI_ScoreEntityLink fvt-id score-id
                        (UDC_FVT|ScoreEntityLink CT_SCORE_ENTITY_SCORE true "|" 0.0 0.0 fvt-id score-id)
                    )
                    (WI_RpsGlobal fvt-id reward-dptf-id
                        (UDC_FVT|RPS|Global true 0.0 0.0 0 0.0 false CT_REWARD_KIND_PLAIN BAR fvt-id reward-dptf-id)
                    )
                    (ref-SCR::XE_CreateFvtLink score-id fvt-id)
                )
                (enforce (= (ref-SCR::UR_SCR|ScoreFvtLink score-id) fvt-id)
                    "REPL_BootstrapTreasury: SCR fvt-link not set after XE_CreateFvtLink")
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
(create-table FVT|T|ScoreEntityLink)                            ;; Key = <FVT-ID> | <Score-Entity-ID>
(create-table FVT|T|MultipletFamily)                            ;; Key = <Multiplet-Family-ID>
(create-table FVT|T|RPS|Global)                                ;; Key = <FVT-ID> | <DPTF-ID>
(create-table FVT|T|RPS|Member)                                ;; Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
(create-table FVT|T|RPS|User)                                   ;; Key = <User-ID> | <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
(create-table FVT|T|MemberUserWeight)                           ;; Key = <User-ID> | <FVT-ID> | <Score-Entity-ID>
(create-table FVT|T|MemberVault)                                ;; Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
(create-table FVT|T|UserPresence)                               ;; Key = <FVT-ID> | <Ouronet-ID>
(create-table FVT|T|ForcedFixCount)                             ;; Key = <FVT-ID> | <DPTF-ID> | <User-ID>