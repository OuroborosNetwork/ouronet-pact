;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface AcquisitionFarmsVaultsTreasuriesV2
    @doc "Interface for the AQP reward-distribution layer (Farms/Vaults/Treasuries). \
        \ Declares readers for FVT config, member score-entity links, RPS (reward-per-share) \
        \ global/member/user/stream accumulators, and per-user presence/weight state; UC_ \
        \ key builders; and the CC_*StakeFlow, CC_Inject/InjectStream/InjectFinalize, \
        \ CC_Collect, CC_SweepRevokeAnchor/SweepBegin, CC_UnstaleMyScores and FVT config C_ \
        \ entrypoints returning IGNIS OutputCumulators."

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
    (defun UCk_ScoreEntityLink:string (fvt-id:string score-entity-id:string))
    (defun UCk_RpsGlobal:string (fvt-id:string dptf-id:string))
    (defun UCk_RpsMember:string (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UCk_RpsUser:string (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [UR]  read
    ;;
    (defun UR_FVT|CanUpgrade:bool (fvt-id:string))
    (defun UR_FVT|CanChangeOwner:bool (fvt-id:string))
    (defun UR_FVT|VacateFrozen:bool (fvt-id:string))
    (defun UR_FVT|CommonDenominator:string (fvt-id:string))
    (defun UR_FVT|OracleOn:bool (fvt-id:string))
    (defun UR_FVT|FvtId:string (fvt-id:string))
    ;;
    ;;
    ;;
    ;;
    ;;
    (defun UR_FVT|SweepActive:bool (anchor-id:string))
    ;; [URH] heavy-read
    ;;
    ;; [URCi]   cost readers — single source for exec billing + INFO preview
    (defun URCi_Issue:object{IgnisCollectorV2.OutputCumulator} (owner-konto:string output:[string]))
    (defun URCi_IssueStoa:decimal ())
    (defun URCi_IssueMultipletFamily:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string]))
    (defun URCi_UnstaleMyScores:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string]))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;; [XE]
    (defun XE_SweepBegin:string (anchor-id:string))
    (defun XE_SweepEnd:string (anchor-id:string))
    (defun XE_SetFvtVacateFrozen:string (fvt-id:string frozen:bool))
    (defun XE_SetFvtOracleOn:string (fvt-id:string oracle-on:bool))
    (defun XE_RefreshTrueFungibleStakeAnchors:object{IgnisCollectorV2.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
    )
    (defun XE_RefreshCollectableStakeAnchors:object{IgnisCollectorV2.OutputCumulator}
        (
            beneficiary-id:string
            collectable-id:string
            son:bool
            nonces:[integer]
            nonce-amounts:[integer]
            direction:bool
        )
    )
    ;; [XB]
    (defun XB_FvtInject:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    ;;{5.7}  User [A/C]
    (defun C_SetQualitySplit:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
    )
    ;; [C]   client
    ;;
    (defun CC_TrueFungibleStakeFlow:object{IgnisCollectorV2.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
    )
    (defun CC_OrtoFungibleStakeFlow:object{IgnisCollectorV2.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
    )
    (defun CC_CollectableStakeFlow:object{IgnisCollectorV2.OutputCumulator}
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
    (defun C_Issue:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
    )
    (defun C_RotateOwnership:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string new-owner-konto:string)
    )
    (defun C_Control:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
    )
    (defun C_SetCommonDenominator:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string common-denominator:string)
    )
    (defun C_SetMosaic:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string mosaic:bool)
    )
    (defun C_SetSplitMode:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string split-mode:string)
    )
    (defun C_AddScoreEntity:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string)
    )
    (defun C_ToggleScoreEntityLink:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
    )
    (defun C_IssueMultipletFamily:object{IgnisCollectorV2.OutputCumulator}
        (
            patron:string
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
        )
    )
    (defun C_AddRewardLink:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
    )
    (defun C_ToggleRewardLink:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string enabled:bool)
    )
    (defun CC_InjectStream:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
    )
    (defun CC_Inject:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun CCp_InjectFixChunk:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
    )
    (defun CC_InjectFinalize:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun CCp_UnstaleAll:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
    )
    (defun CC_SweepRevokeAnchor:string (patron:string anchor-id:string))
    (defun CC_SweepBegin:string (patron:string anchor-id:string))
    (defun CCp_SweepRecomputeChunk:string (patron:string anchor-id:string chunk:integer))
    (defun CC_UnstaleMyScores:object{IgnisCollectorV2.OutputCumulator} (patron:string fvt-ids:[string]))
    (defun CC_Collect:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
    )


    ;;<=====================================================================>
    ;;  #75 FACADE — reward-engine readers re-exported from RPS (see 04_RPS.pact)
    (defun URC_CollectClaimableRewards:decimal (patron:string pool-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string))
    (defun URC_FvtUserStillPresent:bool (fvt-id:string user-id:string))
    (defun URC_InjectDenominator:decimal (fvt-id:string))
    (defun URC_LiveClaimable:decimal (user-id:string fvt-id:string pool-id:string score-entity-type:integer score-entity-id:string dptf-id:string))
    (defun URC_MemberEffectiveCapture:decimal (fvt-id:string score-entity-id:string))
    (defun URC_MemberLevel2Weight:decimal (fvt-id:string score-entity-type:integer score-entity-id:string swpair:string))
    (defun URC_PoolEmployedScoresFvtStakeReady:bool (pool-id:string))
    (defun URC_ScoreEntityUserWeight:decimal (user-id:string fvt-id:string pool-id:string score-entity-type:integer score-entity-id:string))
    (defun URC_StakeScoreDeltaSum:decimal (pool-id:string))
    (defun URC_StreamStatus:object (fvt-id:string dptf-id:string))
    (defun URC_UserTier1AvailableRewards:decimal (user-id:string fvt-id:string score-entity-id:string dptf-id:string deb-user:decimal))
    (defun URCi_CollectFull:decimal (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string))
    (defun URH_FvtEnabledScoreEntityIdsForFvt:[string] (fvt-id:string))
    (defun URH_FvtPresentUsers:[string] (fvt-id:string))
    (defun URH_FvtStalePresentUsers:[string] (fvt-id:string))
    (defun UR_ExternalOracle:bool ())
    (defun UR_FVT-FFC|Count:integer (fvt-id:string dptf-id:string user-id:string))
    (defun UR_FVT-MV|AvailableRewards:decimal (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-QS|BronzeSplit:[integer] (fvt-id:string dptf-id:string))
    (defun UR_FVT-QS|GoldSplit:[integer] (fvt-id:string dptf-id:string))
    (defun UR_FVT-QS|Mode:string (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|AvailableRewards:decimal (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|CurrentRps:decimal (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|RewardEnabled:bool (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|RewardKind:string (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|RoyaltyRewards:decimal (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|StreamCount:integer (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|StreamUnreleased:decimal (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|UnclaimedCount:integer (fvt-id:string dptf-id:string))
    (defun UR_FVT-RG|ZombieRewards:decimal (fvt-id:string dptf-id:string))
    (defun UR_FVT-RM|LastFarmRpsG:decimal (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RM|MemberDebRps:decimal (fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RU|LastRps:decimal (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-RU|PendingRewards:decimal (user-id:string fvt-id:string score-entity-id:string dptf-id:string))
    (defun UR_FVT-SEL|CaptureUnits:decimal (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|CaptureWeight:decimal (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|Delegation:bool (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|Enabled:bool (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|GhostTvlWeight:decimal (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|OracleTs:time (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|ScoreEntityType:integer (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|Swpair:string (fvt-id:string score-entity-id:string))
    (defun UR_FVT-SEL|TotalLaneWeight:decimal (fvt-id:string score-entity-id:string))
    (defun UR_FVT-UP|IsPresent:bool (fvt-id:string ouronet-account:string))
    (defun UR_FVT|EnabledRewardCount:integer (fvt-id:string))
    (defun UR_FVT|FvtClass:integer (fvt-id:string))
    (defun UR_FVT|MembershipMode:string (fvt-id:string))
    (defun UR_FVT|Mosaic:bool (fvt-id:string))
    (defun UR_FVT|OwnerKonto:string (fvt-id:string))
    (defun UR_FVT|SplitMode:string (fvt-id:string))
    (defun UR_FVT|TotalDebScore:decimal (fvt-id:string))
    (defun UR_FVT|TotalGhostTvlWeight:decimal (fvt-id:string))
    (defun UR_OracleValidity:integer ())
)
(module AQP-FVT GOV
    @doc "Large sovereign reward-accounting module for AQP farms (class 0), vaults (1) and \
        \ treasuries (2). Uses a UrStoa-style RPS (reward-per-share) model across \
        \ global/member/user/stream tables plus member vaults, user presence/weight mirrors, \
        \ quality-splits, forced-fix counts, vacate-freeze and DSA agency-fee/oracle rows. \
        \ Drives the multi-phase stake/unstake settle, reward inject (incl. streamed and \
        \ enforced-fresh), collect, deb-staleness fixes, and the re-score anchor-sweep \
        \ recompute; composes AQP-POOL/SCORE/ANK."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements AcquisitionFarmsVaultsTreasuriesV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;(implements DemiourgosPactDigitalCollectibles-UtilityPrototype)
    ;;
    (defconst GOV|MD_FVT                                (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|FVT_ADMIN)))
    (defcap GOV|FVT_ADMIN ()                            (enforce-guard GOV|MD_FVT))
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
    (deftable P|T:{OuronetPolicyV2.P|S})                      ;; Key = <policy-name>
    ;;  PURPOSE: Named keyset guards for this module (OuronetPolicyV2). Used by GOV|FVT_ADMIN and IMP registration.
    (deftable P|MT:{OuronetPolicyV2.P|MS})                     ;; Key = P|I (module-identity constant)
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
        (at "m-policies" (read P|MT P|I ["m-policies"]))
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
                    (ref-U|LST:module{StringProcessorV2} U|LST)
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
                (ref-P|SCR:module{OuronetPolicyV2} AQP-SCORE)
                (ref-P|AQP:module{OuronetPolicyV2} AQP-POOL)
                (ref-P|RPS:module{OuronetPolicyV2} RPS)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|SWPLC:module{OuronetPolicyV2} SWPLC)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|ATSU:module{OuronetPolicyV2} ATSU)
                ;;
                (dg:guard (create-capability-guard (SECURE)))
                (mg:guard (create-capability-guard (P|FVT|CALLER)))
                (rg:guard (create-capability-guard (P|FVT|REMOTE-GOV)))
            )
            ;; #75 B': FVT drives the RPS reward engine via RPS::XE_ — register FVT's SECURE guard on RPS IMP.
            (ref-P|RPS::P|A_AddIMP dg)
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
    (defconst BAR                                       (CT_Bar))
    (defconst AQP|SC_NAME                               (CT_AqpScName))
    (defconst GAS|ISSUE-FVT                             1000.0)
    (defconst GAS|ADD-SCORE-ENTITY                      500.0)
    (defconst GAS|ISSUE-MULTIPLET-FAMILY                500.0)
    (defconst GAS|TOGGLE-SCORE-ENTITY-LINK              500.0)
    (defconst GAS|SET-MOSAIC                            500.0)
    (defconst GAS|ADD-REWARD-LINK                       500.0)
    (defconst GAS|TOGGLE-REWARD-LINK                    500.0)
    (defconst GAS|SET-QUALITY-SPLIT                     500.0)
    (defconst GAS|SET-COMMON-DENOMINATOR                500.0)
    (defconst GAS|SET-SPLIT-MODE                        500.0)
    (defconst GAS|INJECT                                500.0)
    (defconst GAS|COLLECT                               500.0)
    (defconst GAS|UNSTALE                               500.0)
    (defconst CT_REWARD_KIND_PLAIN                      "PLAIN")
    (defconst CT_REWARD_KIND_MULTIPLET_BASE             "MULTIPLET_BASE")
    ;; Round B: a MULTIPLET_BASE triplet reward line can split each lane HOMOGENEOUSLY (each lane → one ladder
    ;; token: bronze→token-0, silver→token-1, gold→token-2) or HETEROGENEOUSLY (each lane → all 3 ladder tokens
    ;; per a stored per-mille matrix). Absent config ⇒ HOMOGENEOUS (unchanged behavior).
    (defconst CT_REWARD_MODE_HOMOGENEOUS                "HOMOGENEOUS")
    (defconst CT_REWARD_MODE_HETEROGENEOUS              "HETEROGENEOUS")
    (defconst CT_SCORE_ENTITY_SCORE                     1)
    (defconst CT_SCORE_ENTITY_TRIPLET                   3)
    (defconst CT_MEMBERSHIP_MODE_BAR                    "BAR")
    (defconst CT_MEMBERSHIP_MODE_SCORE                  "SCORE")
    (defconst CT_MEMBERSHIP_MODE_TRUE_TRIPLET           "TRUE-TRIPLET")
    (defconst CT_MEMBERSHIP_MODE_STANDARD_TRIPLET       "STANDARD-TRIPLET")
    ;; Farm reward-split modes (D1-G2). Level-2 W_i source at inject; per-farm, freely mutable.
    (defconst CT_SPLIT_MODE_STAKED                      "SPLIT|STAKED") ;; Variant 1 — participation (farm default): W_i = member STAKED value (URC_MemberStakedStoaValue)
    (defconst CT_SPLIT_MODE_TVL                         "SPLIT|TVL")    ;; Variant 2 — pool-size: W_i = whole swpair TVL (UR_StoaValue)
    (defconst CT_SPLIT_MODE_NA                          "|")            ;; sentinel — split-mode is farm-only; vaults/treasuries store this and never consult it
    ;;{3.2}  schemas
    ;;
    (defschema FVT|Schema
        @doc "Key = <FVT-ID>. One farm, vault, or treasury (FVT) entity: class, owner, enabled-reward-count, SCORE aggregate mirrors. \
            \ Farm (fvt-class 0): common-denominator + total-ghost-tvl-weight S is inject denominator. \
            \ Vault/Treasury: total-deb-score mirror for inject; common-denominator sentinel \"|\"; total-ghost-tvl-weight 0.0. \
            \ UrStoa analogue: vault header (urstoa-supply on SCORE side; S or total-deb here is FVT-side denominator). \
            \ Field tags: [.] fixed at issue; [..] fixed once set; [M] mutable; [Mu] mutable only under owner + can-upgrade."
        can-upgrade:bool
        can-change-owner:bool
        common-denominator:string                               ;;[Mu]  unsafe to change after ScoreEntityLinks
        oracle-on:bool                                          ;;[M]   DSA: node/uptime oracle governs capture. Default false.
        ;; fvt-class, owner-konto, mosaic, membership-mode, split-mode + the reward aggregates
        ;; live in FVT|RewardAggregate (#75 B' Stage 1/2) — the reward engine reads/owns them.
        ;;Select Keys
        fvt-id:string
    )
    ;; duplicate copies of moved schemas (structural types referenced by staying FVT — #75 B' Stage 3)
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
    (defschema FVT|RPS|User
        @doc "Key = <User-ID> | <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>. Per-staker row."
        last-rps:decimal
        pending-rewards:decimal
        user-id:string
        fvt-id:string
        score-entity-id:string
        dptf-id:string
    )
    (defschema FVT|RewardAggregate
        @doc "Key = <FVT-ID>. Reward-computation aggregates split out of FVT|Schema (#75 B' Stage 1) so \
            \ the reward orchestration owns them; identity/config stays in FVT|Schema."
        fvt-class:integer                                       ;;[.]   0=Farm · 1=Vault · 2=Treasury (moved here #75 B' Stage 2)
        owner-konto:string                                      ;;      entity owner (moved #75 B' Stage 2b)
        mosaic:bool                                             ;;[Mu]  mix score + triplet entities when true
        membership-mode:string                                  ;;[Mu]  BAR | SCORE | TRUE-TRIPLET | STANDARD-TRIPLET
        split-mode:string                                       ;;[M]   Farm reward-split: SPLIT|STAKED | SPLIT|TVL
        total-ghost-tvl-weight:decimal                          ;;[M]   Farm S = sum enabled ScoreEntityLink W_i
        total-base-score:decimal
        total-boosted-score:decimal
        total-deb-score:decimal
        total-nzs-count:integer
        enabled-reward-count:integer
        member-link-count:integer                               ;;[M]   ScoreEntityLink rows (gates C_SetMosaic)
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
    ;;{3.3}  tables
    ;;
    (deftable FVT|T:{FVT|Schema})                               ;; Key = <FVT-ID>
      ;; Key = <FVT-ID>  (#75 B' Stage 1)
      ;; Key = <FVT-ID> | <Score-Entity-ID>
      ;; Key = <Multiplet-Family-ID>
                ;; Key = <FVT-ID> | <DPTF-ID>
                ;; Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
                    ;; Key = <User-ID> | <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
                ;; Key = <FVT-ID> | <DPTF-ID> | <position 1..49>
    ;; Key = <User-ID> | <FVT-ID> | <Score-Entity-ID>
              ;; Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>
            ;; Key = <FVT-ID> | <Ouronet-ID>
        ;; Key = <FVT-ID> | <DPTF-ID> | <User-ID>
    (deftable FVT|T|VacateFreeze:{FVT|VacateFreeze})            ;; Key = <FVT-ID>
    (deftable FVT|T|SweepProgress:{FVT|SweepProgress})          ;; Key = <Anchor-ID>
      ;; Key = FVT|DSA-ORACLE-KEY (single global row)
                  ;; Key = <FVT-ID> | <Score-Entity-ID>
            ;; Key = <FVT-ID> | <DPTF-ID>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap FVT|C>ISSUE-FVT
        (fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
        @doc "Issue one FVT|T row: autostake fvt-name, owner, class 0..2, farm common-denominator or vault/treasury \"|\". Composes SECURE for XI_IssueFvt."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (fvt-id:string (ref-U|DALOS::UDC_Makeid fvt-name))
            )
            (enforce
                (fold (and) true
                    [
                        (>= fvt-class 0)
                        (<= fvt-class 2)
                        (not (ref-RPS::URC_FvtExists fvt-id))
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
    )
    (defcap FVT|C>ROTATE-OWNERSHIP-FVT (fvt-id:string new-owner-konto:string)
        @doc "Rotate FVT owner-konto: current owner, can-change-owner true, distinct new standard account. Composes SECURE."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (owner-now:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
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
    )
    (defcap FVT|C>CONTROL-FVT (fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Update FVT can-upgrade and can-change-owner: owner ownership and current can-upgrade true. Composes SECURE."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (can-upgrade:bool (UR_FVT|CanUpgrade fvt-id))
            )
            (enforce can-upgrade "FVT control update requires can-upgrade true")
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (compose-capability (SECURE))
        )
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
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (ref-RPS::URC_FvtScoreEntityLinkRowExists fvt-id score-entity-id) "ScoreEntityLink row must exist")
            (enforce (= score-entity-type (ref-RPS::UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id)) "score-entity-type mismatch")
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (compose-capability (SECURE))
        )
    )
    )
    (defcap FVT|C>ADD-REWARD-LINK
        (fvt-id:string reward-dptf-id:string segmentation:bool reward-kind:string multiplet-family-id:string)
        @doc "Insert FVT|T|RPS|Global with reward-enabled true. FVT owner; issued reward DPTF. Composes SECURE."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (ref-RPS::UEV_AddRewardLinkContext fvt-id reward-dptf-id reward-kind multiplet-family-id)
        (compose-capability (SECURE))
    )
    )
    (defcap FVT|C>SET-QUALITY-SPLIT
        (fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
        @doc "Set a MULTIPLET_BASE reward's quality-split mode + heterogeneous matrix. FVT owner. Composes SECURE."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (ref-RPS::UEV_QualitySplitContext fvt-id reward-dptf-id mode bronze-split silver-split gold-split)
        (compose-capability (SECURE))
    )
    )
    (defcap FVT|C>SET-SPLIT-MODE (fvt-id:string split-mode:string)
        @doc "Set the farm reward-split mode (D1-G2): SPLIT|STAKED (participation) | SPLIT|TVL (pool-size). Farm \
            \ (class 0) only; FVT owner; FREELY mutable (no cooldown) — a change re-weights only FUTURE injects \
            \ (RPS is checkpoint-based, past rewards untouched). Composes SECURE."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
            )
            ;; 1] farm-only + valid mode value (two boolean conditions → one enforce)
            (enforce
                (and (= (ref-RPS::UR_FVT|FvtClass fvt-id) 0)
                     (or (= split-mode CT_SPLIT_MODE_STAKED) (= split-mode CT_SPLIT_MODE_TVL)))
                "Split-mode: farm (class 0) only, value must be SPLIT|STAKED or SPLIT|TVL")
            ;; 2] owner authorization
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (compose-capability (SECURE))
        )
    )
    )
    (defcap FVT|C>TOGGLE-REWARD-LINK (fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Toggle RPS|Global.reward-enabled; ±1 enabled-reward-count on flip. FVT owner. Composes SECURE."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
            )
            (enforce (ref-RPS::URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) "Reward link row must exist")
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
            (compose-capability (SECURE))
        )
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
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (enforce (not (UR_FVT|VacateFrozen fvt-id)) "FVT is frozen: a pool it serves is mid-vacate")
        (enforce (and (ref-RPS::URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) (ref-RPS::UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id))
            "Reward link row must exist and be enabled for a fix pass")
        (enforce (and (> chunk 0) (<= chunk INJECT-FIX-CHUNK-MAX))
            "Inject-fix chunk out of range — the UI sizes it by simulation, the gas meter is the real ceiling")
        (compose-capability (P|SECURE-CALLER))
    )
    )
    (defcap FVT|C>UNSTALE-ALL (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
        @doc "Protects the OWNER-run mass deb-unstale (CCp_UnstaleAll): the FVT entity owner force-refreshes up to \
            \ `chunk` currently-stale present stakers to make the entity INJECTION-READY, WITHOUT injecting. Uses \
            \ the SAME penalized fix as an inject's fix-phase (ref-RPS::XE_XI_FixUserFvtDebPenalizedIn records the 2e forced-fix \
            \ count on (fvt, reward-dptf, user) → the user reimburses it in non-discountable IGNIS at his next \
            \ collect of this lane), so a standalone prep and a real inject tag stale users identically. Validates \
            \ the SAME reward context as an inject (not vacate-frozen, reward link row exists + enabled) minus the \
            \ amount, plus the `chunk` bound. Unlike the permissionless inject-fix (part of a billed inject flow), \
            \ this standalone op is OWNER-GATED — only the FVT owner may pre-unstale their own entity. Composes \
            \ P|SECURE-CALLER for the intra-module fix + the cross-module XE_RefreshUserScoreDeb into AQP-SCORE."
        @event
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (ref-RPS::UR_FVT|OwnerKonto fvt-id))
        )
        (enforce (not (UR_FVT|VacateFrozen fvt-id)) "FVT is frozen: a pool it serves is mid-vacate")
        (enforce (and (ref-RPS::URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) (ref-RPS::UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id))
            "Reward link row must exist and be enabled for an unstale pass")
        (enforce (and (> chunk 0) (<= chunk INJECT-FIX-CHUNK-MAX))
            "Unstale chunk out of range — the UI sizes it by simulation, the gas meter is the real ceiling")
        (compose-capability (P|SECURE-CALLER))
    )
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
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership patron)
        )
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
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL)
                ;;
                (pool-class-ok:bool (ref-AQP::URC_StakeTrueFungiblePoolClassOk pool-id))
                (stake-admission-ok:bool (if direction (ref-AQP::URC_PoolStakeAdmissionOk pool-id) (ref-AQP::URC_PoolUnstakeAdmissionOk pool-id)))
                (dptf-pool-ok:bool (ref-AQP::URC_StakeTrueFungibleDptfMatchesPool pool-id dptf-id))
                (fvt-ready:bool (if direction (ref-RPS::URC_PoolEmployedScoresFvtStakeReady pool-id) true))
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
            (ref-RPS::UEV_TrueFungibleStakeOwnerAccount owner-id)
            ;;2b] tx sender must own owner-id — AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (CAP_StakeOwner)
            ;;
            ;;3] beneficiary-id
            ;;3a] beneficiary must exist — HERE (DALOS::UEV_EnforceAccountExists)
            ;;3b] beneficiary must be activated standard (non-principal) account — HERE (DALOS::UEV_EnforceAccountType false)
            (ref-RPS::UEV_TrueFungibleStakeBeneficiaryAccount beneficiary-id)
            ;;
            (ref-RPS::UEV_TrueFungibleStakeNotReserved dptf-id)
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
    )
    (defcap FVT|C>ORTO-FUNGIBLE-STAKE-FLOW
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
        @doc "OrtoFungible stake/unstake recipe (direction=true stake, false unstake). \
            \ Whole-nonce DPOF::C_Transfer only — no Transmit / partial segmentation on stake. \
            \ Four phases — no ANK leg (anchors are TF/SF/NF only; DPOF stake does not move anchor balances). \
            \ Phase 1 custody: AQP|XE>ORTO-FUNGIBLE-POOL-CUSTODY."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL)
                ;;
                (stake-admission-ok:bool (if direction (ref-AQP::URC_PoolStakeAdmissionOk pool-id) (ref-AQP::URC_PoolUnstakeAdmissionOk pool-id)))
                (fvt-ready:bool (if direction (ref-RPS::URC_PoolEmployedScoresFvtStakeReady pool-id) true))
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
            (ref-RPS::UEV_TrueFungibleStakeOwnerAccount owner-id)
            ;;3a/3b] beneficiary must exist + be a standard account — BOTH directions (mirror TF flow cap).
            (ref-RPS::UEV_TrueFungibleStakeBeneficiaryAccount beneficiary-id)
            ;;--- UrStoa canonical phases (no 1.3 / 3.x on OF — reserved no-op) ---
            ;; PHASE 1   1.1–1.2 AQP-POOL; 1.3 no-op
            ;; PHASE 2   FVT::XI_RpsPreScore
            ;; PHASE 3   3.1–3.3 no-op
            ;; PHASE 4   SCR::XE_ApplyOrtoFungibleStakeDelta
            ;; PHASE 5   5.1 unclaimed; 5.2 checkpoint
            (compose-capability (SECURE))
        )
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
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL)
                ;;
                (stake-admission-ok:bool (if direction (ref-AQP::URC_PoolStakeAdmissionOk pool-id) (ref-AQP::URC_PoolUnstakeAdmissionOk pool-id)))
                (fvt-ready:bool (if direction (ref-RPS::URC_PoolEmployedScoresFvtStakeReady pool-id) true))
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
            (ref-RPS::UEV_TrueFungibleStakeOwnerAccount owner-id)
            ;; beneficiary must exist + be a standard account — BOTH directions (mirror TF flow cap).
            (ref-RPS::UEV_TrueFungibleStakeBeneficiaryAccount beneficiary-id)
            (compose-capability (SECURE))
        )
    )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Bar ()
        @doc "Returns CT_BAR constant."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    (defun CT_AqpScName:string
        ()
        @doc "Resolves AQP|SC_NAME from canonical AQP-ANK via interface ref."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV2} AQP-ANK)
            )
            (ref-ANK::GOV|AQP|SC_NAME)
        )
    )
    ;;
    ;; [UDC] construct
    ;;
    ;;
    ;; Early UDC: constructors required before UR_* with-default-read default objects.
    (defun UDC_FVT|Schema:object{FVT|Schema}
        (
            can-upgrade:bool
            can-change-owner:bool
            common-denominator:string
            oracle-on:bool
            fvt-id:string
        )
        @doc "Core constructor for object{FVT|Schema} (identity/config). oracle-on (DSA toggle) passes through. \
            \ owner-konto/mosaic/membership-mode/split-mode moved to FVT|RewardAggregate (#75 B' Stage 2b)."
        {"can-upgrade"              : can-upgrade
        ,"can-change-owner"         : can-change-owner
        ,"common-denominator"       : common-denominator
        ,"oracle-on"                : oracle-on
        ,"fvt-id"                   : fvt-id}
    )
    (defun UDC_FVT|RewardAggregate:object{FVT|RewardAggregate}
        (
            fvt-class:integer
            owner-konto:string
            mosaic:bool
            membership-mode:string
            split-mode:string
            total-ghost-tvl-weight:decimal
            total-base-score:decimal
            total-boosted-score:decimal
            total-deb-score:decimal
            total-nzs-count:integer
            enabled-reward-count:integer
            member-link-count:integer
            fvt-id:string
        )
        @doc "Constructor for object{FVT|RewardAggregate} — fvt-class + entity config the reward engine owns + reward aggregates (#75 B' Stage 1/2)."
        {"fvt-class"                : fvt-class
        ,"owner-konto"              : owner-konto
        ,"mosaic"                   : mosaic
        ,"membership-mode"          : membership-mode
        ,"split-mode"               : split-mode
        ,"total-ghost-tvl-weight"   : total-ghost-tvl-weight
        ,"total-base-score"         : total-base-score
        ,"total-boosted-score"      : total-boosted-score
        ,"total-deb-score"          : total-deb-score
        ,"total-nzs-count"          : total-nzs-count
        ,"enabled-reward-count"     : enabled-reward-count
        ,"member-link-count"        : member-link-count
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
    (defun UDC_FVT|SettleScorePlan:object{FVT|SettleScorePlan}
        (score-entity-type:integer score-entity-id:string fvt-id:string reward-dptf-ids:[string])
        @doc "Constructor for object{FVT|SettleScorePlan} — one URC_SettleScorePlanRows entry."
        {"score-entity-type" : score-entity-type
        ,"score-entity-id"   : score-entity-id
        ,"fvt-id"            : fvt-id
        ,"reward-dptf-ids"   : reward-dptf-ids}
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
    (defun UCk_ForcedFixCount:string (fvt-id:string dptf-id:string user-id:string)
        @doc "Composite key for FVT|T|ForcedFixCount: fvt-id | dptf-id | user-id."
        (concat [fvt-id BAR dptf-id BAR user-id])
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
    (defun UC_EmptyOc:object{IgnisCollectorV2.OutputCumulator} ()
        @doc "Empty OutputCumulator for write-only inject/collect phase slots."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;; [URCi]   multi-leg STAKE/UNSTAKE flow ifp readers — relocated from AQP-INFO (byte-identical ifp sums).
    ;;   Mirror CC_*StakeFlow leg-for-leg; every leg gated by the virtual-gas toggle so toggle-on -> 0.
    ;;   Tier gates below reproduce the UsagePrice tier behind URC_IsVirtualGasZero);
    ;;   AQP-VCT's vacate readers reach them + the two score-delta sums cross-module. Leg map:
    ;;   memories/2026-08-27-aqp-info-final17-costmap.md
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [UR]  read
    ;; FVT|T|MemberVault  Key = <FVT-ID> | <Score-Entity-ID> | <DPTF-ID>  (Tier-1 dust sweep, M1/#10)
    ;;
    ;;
    ;;
    ;; Reads follow schema order: (1) FVT|Schema (2) ScoreEntityLink (3) MultipletFamily (4) RPS|Global (5) RPS|Member (6) RPS|User
    ;;
    (defun UR_FVT|Fvt:object{FVT|Schema} (fvt-id:string)
        @doc "Reads full FVT definition row from FVT|T."
        (read FVT|T fvt-id)
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
    (defun UR_FVT|OracleOn:bool (fvt-id:string)
        @doc "DSA: does the node/uptime oracle govern capture on this FVT? false ⇒ capture = units, uptime ≡ 1000, no expiry."
        (at "oracle-on" (read FVT|T fvt-id ["oracle-on"]))
    )
    (defun UR_FVT|FvtId:string (fvt-id:string)
        @doc "Reads fvt-id field from FVT row."
        (at "fvt-id" (read FVT|T fvt-id ["fvt-id"]))
    )
    ;;
    ;;
    ;;
    ;;
    ;;
    ;;
    ;; --- Cap / stake-flow validation (cheap bools; no keys/select) ---
    ;; URH_FvtScoreEntityLinkKeysForFvt ((keys FVT|T|ScoreEntityLink) scan) RETIRED — M2/#11. Its only caller was
    ;; the vault inject-denominator scan, now replaced by the incrementally-maintained total-deb-score mirror.
    ;; URC_FvtVaultDebDenominator (vault inject divisor via keys-scan) RETIRED — M2/#11. The divisor is now the
    ;; maintained total-deb-score mirror (incrementally kept at stake/toggle/add, point-read at inject). No scan.
    (defun URC_MaxStreamLanes:integer (account:string)
        @doc "Max concurrent streamed injects the FVT owner konto may run, by Elite tier (snapshot at inject, D5). \
            \ Smart accounts have no Elite level, so they resolve to their sovereign standard account. \
            \ slots = max(1, (major-1)*7 + minor): everyone gets >= 1, capped at STREAM_MAX_LANES (49 at tier 7.7)."
        (let*
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL)
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-SWP:module{SwapperV4} SWP)
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
                (ref-SWP:module{SwapperV4} SWP)
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
                (ref-SWP:module{SwapperV4} SWP)
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
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
    (defun URC_ComputeTripletLanes:object
        (user-id:string pool-id:string triplet-id:string)
        @doc "Lane weights from silver base-score × ANK promiles on bronze/silver/golden boost-class-links."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-ANK:module{AcquisitionAnchorsV2} AQP-ANK)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
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
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
    (defun URC_ResolvePoolScoreId:string (score-entity-type:integer score-entity-id:string)
        @doc "Pool id for collect/settle SCR reads: score pool or triplet silver pool."
        (let 
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
            )
            (if (= score-entity-type CT_SCORE_ENTITY_SCORE)
                (ref-SCR::UR_SCR|ScoreAqpoolLink score-entity-id)
                (ref-SCR::UR_SCR|ScoreAqpoolLink
                    (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id)
                )
            )
        )
    )
    ;; --- Phase 2.1 settle · lists, plans, IGNIS ---
    ;; --- Phase 2.35 unclaimed · IGNIS ---
    ;; --- Phase 2.4 checkpoint · IGNIS ---
    ;; --- Shared deb-staleness SCAN predicates (M3 #12 — scan + fix use the SAME predicate, cannot diverge) ---
    (defun URC_FvtMemberDebNeedsFix:bool
        (fvt-id:string user-id:string score-entity-type:integer score-entity-id:string)
        @doc "True iff (user, member) is deb-based (singular / NON-true triplet) AND deb-stale — the exact condition \
            \ XI_FixUserMemberDeb acts on. Shared by the sweep scan so scan and fix never disagree. True triplets \
            \ (deb-independent lanes) → always false."
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
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
    ;; FVT|T|AgencyFee  Key = <FVT-ID> | <Score-Entity-ID>  (DSA operator-fee mirror; Phase 5b)
    ;; FVT|T|QualitySplit  Key = <FVT-ID> | <DPTF-ID>  (DSA Round B heterogeneous split matrix)
    ;; [URH] heavy-read
    ;;
    ;; --- FVT|T|RPS|Global selects (stake hot path: one batched select via URH_FVT|SettleFvtRewardBundle) ---
    ;; [URCi]   cost readers — single source for exec billing + INFO preview
    (defun URCi_Issue:object{IgnisCollectorV2.OutputCumulator} (owner-konto:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV2} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator GAS|ISSUE-FVT owner-konto (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_IssueStoa:decimal ()
        (let
            (
                (d:module{OuronetDalosV2} DALOS)
            )
            (d::UR_UsagePrice "smart")
        ))
    (defun URCi_IssueMultipletFamily:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string])
        (let
            (
                (r:module{IgnisCollectorV2} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator GAS|ISSUE-MULTIPLET-FAMILY patron (r::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_UnstaleMyScores:object{IgnisCollectorV2.OutputCumulator} (patron:string output:[string])
        @doc "GAS|UNSTALE gas leg (konto = patron); exec concats it with the per-fvt unstale walk."
        (let
            (
                (r:module{IgnisCollectorV2} IGNIS)
            )
            (r::UDC_ConstructOutputCumulator GAS|UNSTALE patron (r::URC_IsVirtualGasZero) output)
        ))
    ;; [URCi]   DSA royalty-disposal CUSTODY-move ifp readers — read-only mirror of the XE_*Royalty custody legs
    ;;   (the DSA A_*Royalty exec concats URCi_*Royalty gas leg with the FVT XE_*Royalty custody cumulator).
    ;;   The disposal amount/token are reconstructed from the live royalty pool balance + IGNIS-normalize decision.
    ;; [URCi/URC]   CC_Collect FULL-cost readers — read-only mirror of the reward-payout leg (XI_TransferRewardDptfFromVault:
    ;;   plain single TFT transfer, or a MULTIPLET_BASE triplet Coil/Curl ladder, homogeneous or heterogeneous) + the
    ;;   Phase-7 forced-fix penalty + GAS|COLLECT. The payout is derived on the CURRENT (pre-drip) claimable state —
    ;;   exact for un-streamed / settled lanes (see URCi_CollectFull residual note).
    ;;{5.4}  Validate [UEV/CAP]
    ;; [UEV] enforce
    (defun UEV_SetMosaicContext (fvt-id:string mosaic:bool)
        @doc "C_SetMosaic: owner, can-upgrade, zero member-link-count."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (can-upgrade:bool (UR_FVT|CanUpgrade fvt-id))
            )
            (enforce can-upgrade "FVT mosaic update requires can-upgrade true")
            (enforce
                (= (ref-RPS::UR_FVT|MemberLinkCount fvt-id) 0)
                "Cannot change mosaic while ScoreEntityLink rows exist"
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner-konto)
        )
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
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (fvt-class:integer (ref-RPS::UR_FVT|FvtClass fvt-id))
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
                (or (ref-RPS::UR_FVT|Mosaic fvt-id)
                    (let
                        (
                            (mode:string (ref-RPS::UR_FVT|MembershipMode fvt-id))
                        )
                        (or (= mode CT_MEMBERSHIP_MODE_BAR) (= mode CT_MEMBERSHIP_MODE_SCORE))
                    ))
                "Non-mosaic FVT locked to score membership only")
            (enforce
                (fold (and) true
                    [(not (ref-RPS::URC_FvtScoreEntityLinkRowExists fvt-id score-id))
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
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (fvt-owner:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (fvt-class:integer (ref-RPS::UR_FVT|FvtClass fvt-id))
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
                (or (ref-RPS::UR_FVT|Mosaic fvt-id)
                    (let
                        (
                            (mode:string (ref-RPS::UR_FVT|MembershipMode fvt-id))
                        )
                        (or (= mode CT_MEMBERSHIP_MODE_BAR)
                            (and (= mode CT_MEMBERSHIP_MODE_TRUE_TRIPLET) is-true-triplet)
                            (and (= mode CT_MEMBERSHIP_MODE_STANDARD_TRIPLET) (not is-true-triplet)))
                    ))
                "Non-mosaic FVT membership mode mismatch for triplet admission")
            (enforce
                (fold (and) true
                    [(= silver-owner fvt-owner)
                     (not (ref-RPS::URC_FvtScoreEntityLinkRowExists fvt-id triplet-id))
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
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (enforce (not (UR_FVT|VacateFrozen fvt-id)) "FVT is frozen: a pool it serves is mid-vacate")
            (enforce (> amount 0.0) "Inject amount must be positive")
            (enforce (ref-RPS::URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) "Reward link row must exist")
            (enforce (ref-RPS::UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id) "Reward token is disabled for inject")
            (ref-DALOS::UEV_EnforceAccountExists patron)
            (ref-DPTF::UEV_id reward-dptf-id)
            (ref-DPTF::UEV_Amount reward-dptf-id amount)
        )
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
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
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
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL)
                (reward-kind:string (ref-RPS::UR_FVT-RG|RewardKind fvt-id reward-dptf-id))
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
            (enforce (ref-RPS::URC_FvtRpsGlobalRowExists fvt-id reward-dptf-id) "Reward link row must exist")
            (enforce (ref-RPS::UR_FVT-RG|RewardEnabled fvt-id reward-dptf-id) "Reward token is disabled for collect")
            (enforce (ref-RPS::URC_FvtScoreEntityLinkRowExists fvt-id score-entity-id) "ScoreEntityLink row must exist")
            (enforce (ref-RPS::UR_FVT-SEL|Enabled fvt-id score-entity-id) "ScoreEntityLink must be enabled for collect")
            (enforce (= score-entity-type (ref-RPS::UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id)) "score-entity-type mismatch")
            (if (and (= reward-kind CT_REWARD_KIND_MULTIPLET_BASE) (= score-entity-type CT_SCORE_ENTITY_TRIPLET))
                (enforce
                    (fold (and) true
                        [
                            (!= (ref-RPS::UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id) BAR)
                            (ref-RPS::URC_MultipletFamilyExists (ref-RPS::UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
                            (ref-RPS::UR_FVT-MF|Active (ref-RPS::UR_FVT-RG|MultipletFamilyId fvt-id reward-dptf-id))
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
    )
    (defun UEV_SetCommonDenominatorContext (fvt-id:string common-denominator:string)
        @doc "C_SetCommonDenominator: farm only, can-upgrade, no ScoreEntityLinks yet, valid DPTF id."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (can-upgrade:bool (UR_FVT|CanUpgrade fvt-id))
                (fvt-class:integer (ref-RPS::UR_FVT|FvtClass fvt-id))
            )
            (enforce can-upgrade "SetCommonDenominator requires can-upgrade true")
            (enforce (= fvt-class 0) "SetCommonDenominator applies to farm (class 0) FVT only")
            (enforce
                (not (ref-RPS::URC_FvtHasScoreEntityLinks fvt-id))
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
    ;; WU_Fvt|TotalBaseScore — not yet written in this module.
    ;; WU_Fvt|TotalBoostedScore — not yet written in this module.
    ;; WU_Fvt|TotalNzsCount — not yet written in this module.
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
    (defun WU_Fvt|OracleOn:string
        (fvt-id:string oracle-on:bool)
        @doc "DSA: toggle the node/uptime oracle on this FVT."
        (require-capability (SECURE))
        (update FVT|T fvt-id {"oracle-on": oracle-on})
    )
    ;; WU_Fvt|FvtId — select key; WU not needed.
    ;;
    ;; FVT|T|MemberUserWeight  Key = <User-ID> | <FVT-ID> | <Score-Entity-ID>
    ;;
    ;;
    ;;
    ;;
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
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (WI_Fvt fvt-id
            (UDC_FVT|Schema true true common-denominator false fvt-id)
        )
        (ref-RPS::XE_WI_FvtRewardAggregate fvt-id
            ;; split-mode: farm (class 0) default participation; vault/treasury get the "|" sentinel (never read)
            (UDC_FVT|RewardAggregate fvt-class owner-konto true CT_MEMBERSHIP_MODE_BAR
                (if (= fvt-class 0) CT_SPLIT_MODE_STAKED CT_SPLIT_MODE_NA)
                0.0 0.0 0.0 0.0 0 0 0 fvt-id)
        )
    )
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
    ;;
    ;; --- Block A · Phase 4.5 FVT total-deb mirror (post-SCORE) ---
    ;; --- Block A · Phase 4.7 FVT user-presence ADD (M3 #12 / H4 sweep enumeration) ---
    ;;
    ;; --- Block A · Phase 2.1 settle (CC_TrueFungibleStakeFlow) ---
    ;;   XI_RpsPreScore — orchestrator: ghost TVL → ensure rows → bank pending
    ;;     └ (map) → XI_1|EnsureScoreRewardRows, XI_1|BankScorePendingRewards
    ;;
    ;; --- Shared deb-staleness FIX (M3 #12 — used by CC_Inject AND collect PHASE 6 backstop) ---
    ;; --- Shared inject-CORE + cross-module XE_ building blocks (CC_Inject FVT-local; MTX|n|C_Inject via MTX-AQP) ---
    ;;
    ;; --- Block B · Phase 3 anchor refresh (CC_TrueFungibleStakeFlow · 3.1) ---
    ;;   XI_RefreshTrueFungibleStakeAnchors
    ;;     ├ AQP-ANK::XE_UpdateTrueFungibleUserAnchorValues
    ;;     └ AQP-POOL::XB_SetBenDptfAnkSyncCount
    ;;
    ;; --- Anchors (AQP-ANK · TF stake only) ---
    (defun XI_RefreshTrueFungibleStakeAnchors:object{IgnisCollectorV2.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
        @doc "Internal (CC_TrueFungibleStakeFlow phase 3.1 · depth 0]): read post-ico1 BenDptfTotal balance, \
            \ call backward ANK promile refresh + AQP last-ank-sync-count bump; concat IGNIS OCs. \
            \ require-capability (SECURE) only — backward XE_* use P|UEV_IMC / domain caps."
        (require-capability (SECURE))
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL)
                (ref-ANK:module{AcquisitionAnchorsV2} AQP-ANK)
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                ;;
                (total-dptf-amount:decimal (ref-AQP::UR_AQP|BenDptfTotalBalance beneficiary-id dptf-id))
                (ico-ank:object{IgnisCollectorV2.OutputCumulator}
                    (ref-ANK::XE_UpdateTrueFungibleUserAnchorValues beneficiary-id dptf-id total-dptf-amount)
                )
                (ico-aqp:object{IgnisCollectorV2.OutputCumulator}
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
    (defun XI_RefreshCollectableStakeAnchors:object{IgnisCollectorV2.OutputCumulator}
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
                (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL)
                (ref-ANK:module{AcquisitionAnchorsV2} AQP-ANK)
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
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
    ;; --- RPS post-SCORE (UrStoa unclaimed + checkpoint) ---
    ;;
    ;; --- Block C · checkpoint (C_*StakeFlow) ---
    ;;   XI_CheckpointStakeRps — nested map (score plan × reward line); no child XI_*.
    ;;
    ;; [XE]
    (defun XE_SweepBegin:string (anchor-id:string)
        @doc "Sweep bracket BEGIN (paginated MTX|n|C_SweepRevokeAnchor): freeze every affected pool (stake + collect \
            \ blocked) then remove the anchor globally (swept-revoke — skips the #9 score-link lock). Mirrors steps \
            \ 1-2 of the single-tx CC_SweepRevokeAnchor. P|UEV_IMC + FVT|XE>SWEEP-BRACKET (P|SECURE-CALLER)."
        (P|UEV_IMC)
        (with-capability (FVT|XE>SWEEP-BRACKET anchor-id)
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV2} AQP-ANK)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL)
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
                    (ref-ANK:module{AcquisitionAnchorsV2} AQP-ANK)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL)
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
    (defun XE_RefreshTrueFungibleStakeAnchors:object{IgnisCollectorV2.OutputCumulator}
        (beneficiary-id:string dptf-id:string)
        @doc "Forward (stake/unstake flow): recompute the beneficiary's true-fungible stake-anchor values for \
            \ <dptf-id> after a stake delta, keeping the anchor aggregates in sync with the live stake. P|UEV_IMC + SECURE."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_RefreshTrueFungibleStakeAnchors beneficiary-id dptf-id)
        )
    )
    (defun XE_RefreshCollectableStakeAnchors:object{IgnisCollectorV2.OutputCumulator}
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
    ;; [XB]
    (defun XB_FvtInject:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "THE single authorized inject entry — usable BOTH internally (C_Inject delegates here) and externally \
            \ (the MTX|n|C_Inject defpact terminal step calls it cross-module), hence `XB`. Just the auth wrapper: \
            \ P|UEV_IMC + FVT|C>INJECT (validates + composes SECURE) around the one XI_FvtInjectCore. Any FVT class \
            \ (farm/vault/treasury); the core branches on class. Distributes over the CURRENT divisor — enforced- \
            \ fresh callers (CC_Inject / the defpact) fix stale members BEFORE calling. Replaces the former \
            \ XE_FvtInject: after the class-guard removal (N2) it was byte-identical to C_Inject's body, so the two \
            \ collapsed onto this one XB entry."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>INJECT patron fvt-id reward-dptf-id amount)
            (ref-RPS::XE_XI_FvtInjectCore patron fvt-id reward-dptf-id amount)
        )
    )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;; [C]   client
    ;; --- Lifecycle (FVT|T) ---
    (defun C_Issue:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
        @doc "Create a new FVT (Farm | Vault | Treasury). GAS|ISSUE-FVT + smart STOA from patron; returns fvt-id in output."
        (P|UEV_IMC)
        (with-capability (FVT|C>ISSUE-FVT fvt-name owner-konto fvt-class common-denominator)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    ;;
                    (smart-price:decimal (ref-DALOS::UR_UsagePrice "smart"))
                    (fvt-id:string (ref-U|DALOS::UDC_Makeid fvt-name))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::STOA|C_Collect patron (URCi_IssueStoa))
                (XI_IssueFvt fvt-id fvt-class owner-konto common-denominator)
                (URCi_Issue owner-konto [fvt-id])
            )
        )
    )
    ;;Management (FVT|Schema)
    (defun C_RotateOwnership:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string new-owner-konto:string)
        @doc "Transfer FVT owner-konto. Validation in FVT|C>ROTATE-OWNERSHIP-FVT; medium IGNIS on pre-rotate owner."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ico:object{IgnisCollectorV2.OutputCumulator} (ref-RPS::URCi_RotateOwnership fvt-id))
            )
            (with-capability (FVT|C>ROTATE-OWNERSHIP-FVT fvt-id new-owner-konto)
                (ref-RPS::XE_XI_RotateOwnership fvt-id new-owner-konto)
            )
            ico
        )
    )
    )
    (defun C_Control:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Set can-upgrade and can-change-owner on FVT. Medium IGNIS on owner-konto."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
            )
            (with-capability (FVT|C>CONTROL-FVT fvt-id new-can-upgrade new-can-change-owner)
                (XI_Control fvt-id new-can-upgrade new-can-change-owner)
            )
            (ref-RPS::URCi_Control fvt-id)
        )
    )
    )
    (defun C_SetCommonDenominator:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string common-denominator:string)
        @doc "Farm-only: set common-denominator before any ScoreEntityLinks. GAS|SET-COMMON-DENOMINATOR on owner."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>SET-COMMON-DENOMINATOR fvt-id common-denominator)
                (XI_SetCommonDenominator fvt-id common-denominator)
            )
            (ref-RPS::URCi_SetCommonDenominator fvt-id [fvt-id])
        )
    )
    )
    (defun C_SetMosaic:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string mosaic:bool)
        @doc "Toggle mosaic membership policy when FVT has no ScoreEntityLink rows. GAS|SET-MOSAIC on owner."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>SET-MOSAIC fvt-id mosaic)
                (ref-RPS::XE_XI_SetMosaic fvt-id mosaic)
            )
            (ref-RPS::URCi_SetMosaic fvt-id [fvt-id])
        )
    )
    )
    (defun C_SetSplitMode:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string split-mode:string)
        @doc "Set the farm reward-split mode (D1-G2): SPLIT|STAKED (participation, default) | SPLIT|TVL (pool-size). \
            \ Farm owner; FREELY mutable (no cooldown) — a change re-weights only FUTURE injects (RPS is \
            \ checkpoint-based, past rewards untouched). GAS|SET-SPLIT-MODE on owner."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>SET-SPLIT-MODE fvt-id split-mode)
                (ref-RPS::XE_XI_SetSplitMode fvt-id split-mode)
            )
            (ref-RPS::URCi_SetSplitMode fvt-id [fvt-id split-mode])
        )
    )
    )
    ;; --- Score membership (FVT|T|ScoreEntityLink) ---
    (defun C_AddScoreEntity:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string)
        @doc "Register score (type 1) or triplet (type 3) on FVT; insert ScoreEntityLink; SCR fvt-links. GAS|ADD-SCORE-ENTITY."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (fvt-class:integer (ref-RPS::UR_FVT|FvtClass fvt-id))
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
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
                (ref-RPS::XE_XI_AddScoreEntity fvt-id score-entity-type score-entity-id swpair ghost-weight)
            )
            (ref-RPS::URCi_AddScoreEntity fvt-id [fvt-id score-entity-id])
        )
    )
    )
    (defun C_ToggleScoreEntityLink:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string enabled:bool)
        @doc "Turn ScoreEntityLink.enabled on/off; farm adjusts S when toggling. GAS|TOGGLE-SCORE-ENTITY-LINK."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>TOGGLE-SCORE-ENTITY-LINK fvt-id score-entity-type score-entity-id enabled)
                (ref-RPS::XE_XI_ToggleScoreEntityLink fvt-id score-entity-id enabled)
            )
            (ref-RPS::URCi_ToggleScoreEntityLink fvt-id [fvt-id score-entity-id])
        )
    )
    )
    (defun C_IssueMultipletFamily:object{IgnisCollectorV2.OutputCumulator}
        (
            patron:string
            token-0-id:string
            token-1-id:string
            token-2-id:string
            ats-0-1-id:string
            ats-1-2-id:string
        )
        @doc "Issue one chain-wide MultipletFamily reward ladder F|t0|t1|t2."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                ;;
                (family-id:string (ref-RPS::UCk_MultipletFamily token-0-id token-1-id token-2-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>ISSUE-MULTIPLET-FAMILY token-0-id token-1-id token-2-id ats-0-1-id ats-1-2-id)
                (ref-RPS::XE_XI_IssueMultipletFamily token-0-id token-1-id token-2-id ats-0-1-id ats-1-2-id)
            )
            (URCi_IssueMultipletFamily patron [family-id])
        )
    )
    )
    ;; --- Reward token registration (FVT|T|RPS|Global) — atomic one row per reward DPTF ---
    (defun C_AddRewardLink:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string segmentation:bool multiplet-family-id:string)
        @doc "Register one reward DPTF on FVT (single RPS|Global row). multiplet-family-id BAR for plain tokens (VESTA, etc.); \
            \ F|t0|t1|t2 when reward-dptf-id is family token-0 — enables triplet lane collect on triplet anchors; score anchors stay plain. \
            \ One inject feeds all membership tranches; collect branches on anchor-id (score vs triplet)."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (reward-kind:string
                    (if (= multiplet-family-id BAR)
                        CT_REWARD_KIND_PLAIN
                        CT_REWARD_KIND_MULTIPLET_BASE
                    )
                )
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>ADD-REWARD-LINK fvt-id reward-dptf-id segmentation reward-kind multiplet-family-id)
                (ref-RPS::XE_XI_AddRewardLink fvt-id reward-dptf-id segmentation reward-kind multiplet-family-id)
            )
            (ref-RPS::URCi_AddRewardLink fvt-id [fvt-id reward-dptf-id multiplet-family-id])
        )
    )
    )
    (defun C_ToggleRewardLink:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string enabled:bool)
        @doc "Toggle reward-enabled; ±1 enabled-reward-count on flip. GAS|TOGGLE-REWARD-LINK on owner."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>TOGGLE-REWARD-LINK fvt-id reward-dptf-id enabled)
                (ref-RPS::XE_XI_ToggleRewardLink fvt-id reward-dptf-id enabled)
            )
            (ref-RPS::URCi_ToggleRewardLink fvt-id [fvt-id reward-dptf-id])
        )
    )
    )
    (defun C_SetQualitySplit:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string mode:string bronze-split:[integer] silver-split:[integer] gold-split:[integer])
        @doc "Round B: set a MULTIPLET_BASE reward's quality-split MODE + heterogeneous MATRIX. HOMOGENEOUS (default \
            \ when unset) routes each quality lane to its one ladder token (bronze->t0, silver->t1, gold->t2). \
            \ HETEROGENEOUS routes each lane across ALL 3 ladder tokens per its [to-t0 to-t1 to-t2] per-mille row \
            \ (each row sums to 1000). FVT owner; O(1) reprice (no per-delegator recompute). GAS|SET-QUALITY-SPLIT."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                ;;
                (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (with-capability (FVT|C>SET-QUALITY-SPLIT fvt-id reward-dptf-id mode bronze-split silver-split gold-split)
                (ref-RPS::XE_WI_QualitySplit fvt-id reward-dptf-id mode bronze-split silver-split gold-split)
            )
            (ref-RPS::URCi_SetQualitySplit fvt-id [fvt-id reward-dptf-id mode])
        )
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
    ;;    · Farm: Tier-1 denominator S is fresh (ref-RPS::URC_FarmInjectDenominatorFresh), but the Tier-2 per-member
    ;;      L_i-advance divisor is SCR|ScoreTotalDebScore — stale-able for singular / non-true-triplet members
    ;;      (e.g. a mosaic farm carrying a singular score). True-triplet members are deb-independent (lane weights)
    ;;      and the fix no-ops on them.
    ;;   Inject cost scales with MEMBER count (employed score-entities; a triplet = ONE member): a 4-member farm
    ;;   costs one member-iteration more than a 3-member farm.
    ;; ───────────────────────────────────────────────────────────────────────────
    ;;
    (defun CC_InjectStream:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
        @doc "Inject a reward DPTF as a TIME-STREAM — the DELAYED inject path (any FVT class): `amount` vests \
            \ LINEARLY over `duration` seconds (1h..365d) and whoever is staked during each slice earns that slice \
            \ (late stakers included). duration = 0 is not accepted here — use C_Inject for an instant inject. \
            \ Streams are independent + overlap (no merge), capped per the FVT owner konto's Elite tier; a full \
            \ lane accepts only instant injects until a stream finishes. Delegates to XI_FvtAddStream under \
            \ FVT|C>INJECT-STREAM (validate + custody + SECURE). UI: URC_LiveClaimable / URC_StreamStatus show \
            \ real-time accrual. See Audit/STREAMED-INJECT-DESIGN.md."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>INJECT-STREAM patron fvt-id reward-dptf-id amount duration)
            (ref-RPS::XE_XI_FvtAddStream patron fvt-id reward-dptf-id amount duration)
        )
    )
    )
    (defun CC_Inject:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "HEAVY (R3 `CC_`) enforced-FRESH inject for ANY FVT class (farm/vault/treasury) — see the INJECT \
            \ FUNCTION MATRIX above C_Inject. Before injecting, SCAN the FVT's present users (`URH_FvtStalePresentUsers` \
            \ — one select over the purpose-built presence table, populated for every class at stake) and FIX every \
            \ stale member (settle-at-old-deb across all streams → refresh SCORE deb → resync via XI_FixUserFvtDeb), so \
            \ the distribution reflects LIVE debs and is fair to every current staker. Atomic: fixing the whole scanned \
            \ set leaves ZERO stale — NO second scan. Why farms need this too: a farm's Tier-1 denominator S is always \
            \ fresh (ref-RPS::URC_FarmInjectDenominatorFresh), BUT its Tier-2 per-member L_i-advance divisor is the maintained \
            \ SCR|ScoreTotalDebScore mirror, which goes deb-stale for singular / non-true-triplet members (e.g. a \
            \ mosaic farm carrying a singular score) exactly like a vault — the fix un-stales it (true-triplet members \
            \ no-op: deb-independent lanes). Same authorization as C_Inject (FVT|C>INJECT). For spike loads that exceed \
            \ one tx, use the MTX|n|C_Inject defpact (MTX-AQP). UrStoa ≡ C_URV|Inject with a pre-fresh divisor."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>INJECT patron fvt-id reward-dptf-id amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;===>PHASE 0 (CC)=== SCAN the FVT's STALE present users + FIX every stale member (recording
                        ;; the 2e forced-fix count per user) → fresh divisor. Atomic: fixing the whole scanned set ⟹
                        ;; ZERO stale afterward (scan-cut, no re-scan).
                        (let
                            (
                                (members:[string] (ref-RPS::URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
                                (reward-rows:[string] (ref-RPS::URH_FVT-RG|EnabledRewardRows fvt-id))
                            )
                            ;; DRIP each reward lane once (checkpoint) before the fix loop → users settle at now's index
                            (map (lambda (d:string) (ref-RPS::XE_XI_ReleaseStream fvt-id d)) reward-rows)
                            (map (lambda (u:string) (ref-RPS::XE_XI_FixUserFvtDebPenalizedIn fvt-id reward-dptf-id u members reward-rows)) (ref-RPS::URH_FvtStalePresentUsers fvt-id))
                            (UC_EmptyOc)
                        )
                        ;;===>PHASE 1-3=== inject on the now-FRESH divisor (shared core, also driven by the defpact)
                        (ref-RPS::XE_XI_FvtInjectCore patron fvt-id reward-dptf-id amount)
                    ]
                    []
                )
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
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>INJECT-FIX patron fvt-id reward-dptf-id chunk)
            (let
                (
                    (stale:[string] (ref-RPS::URH_FvtStalePresentUsers fvt-id))
                )
                (let
                    (
                        (batch:[string] (take chunk stale))
                        ;; hoist the FVT-invariant member + reward-row lists ONCE for the whole chunk (no per-user re-scan)
                        (members:[string] (ref-RPS::URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
                        (reward-rows:[string] (ref-RPS::URH_FVT-RG|EnabledRewardRows fvt-id))
                    )
                    ;; DRIP each reward lane ONCE (checkpoint) before the fix loop so every user settles against the
                    ;; now-current index (no time passes during the batch tx). No-op when no lane carries a stream.
                    (map (lambda (d:string) (ref-RPS::XE_XI_ReleaseStream fvt-id d)) reward-rows)
                    ;; force-refresh this chunk of stale stakers (penalized); fixed users drop out of the stale set
                    (map (lambda (u:string) (ref-RPS::XE_XI_FixUserFvtDebPenalizedIn fvt-id reward-dptf-id u members reward-rows)) batch)
                    (let
                        (
                            (remaining:integer (- (length stale) (length batch)))
                        )
                        (format "Inject-fix: fixed {} of {} stale staker(s) — {} remain{}." [(length batch) (length stale) remaining (if (= remaining 0) " (ready to CC_InjectFinalize)" ", keep paging")])
                    )
                )
            )
        )
    )
    )
    (defun CC_InjectFinalize:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "FINALIZE a paginated enforced-fresh inject: enforce that NO stale present user remains (the prior \
            \ CCp_InjectFixChunk pages made the divisor live), then inject on the fresh divisor via the shared \
            \ XI_FvtInjectCore — identical outcome to the single-tx CC_Inject and the C_MTX|2|Inject defpact terminal \
            \ step. The zero-stale gate is the enforced-fresh guarantee at the moment of inject (a heavy scan, so it \
            \ lives in the body, not the defcap). P|UEV_IMC + FVT|C>INJECT (same auth as any inject)."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>INJECT patron fvt-id reward-dptf-id amount)
            ;; enforced-fresh gate: refuse to inject while any present staker is stale (page CCp_InjectFixChunk first).
            ;; The URH_ scan (select) MUST be computed in a let, NOT inside the enforce — Pact evaluates an enforce
            ;; predicate in read-only/sys-only mode, where select is disallowed. Fires before XI_FvtInjectCore's
            ;; custody transfer, so an aborted finalize moves no funds.
            (let
                (
                    (stale-remaining:integer (length (ref-RPS::URH_FvtStalePresentUsers fvt-id)))
                )
                (enforce (= 0 stale-remaining)
                    "Stale stakers remain — page CCp_InjectFixChunk until none remain before finalizing (or use single-tx CC_Inject)")
                (ref-RPS::XE_XI_FvtInjectCore patron fvt-id reward-dptf-id amount)
            )
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
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>UNSTALE-ALL patron fvt-id reward-dptf-id chunk)
            (let
                (
                    (stale:[string] (ref-RPS::URH_FvtStalePresentUsers fvt-id))
                )
                (let
                    (
                        (batch:[string] (take chunk stale))
                        ;; hoist the FVT-invariant member + reward-row lists ONCE for the whole chunk (no per-user re-scan)
                        (members:[string] (ref-RPS::URH_FvtEnabledScoreEntityIdsForFvt fvt-id))
                        (reward-rows:[string] (ref-RPS::URH_FVT-RG|EnabledRewardRows fvt-id))
                    )
                    ;; DRIP each reward lane ONCE (checkpoint) before the fix loop so every user settles against the
                    ;; now-current index (no time passes during the batch tx). No-op when no lane carries a stream.
                    (map (lambda (d:string) (ref-RPS::XE_XI_ReleaseStream fvt-id d)) reward-rows)
                    ;; force-refresh this chunk of stale stakers (penalized — records the 2e forced-fix count); fixed
                    ;; users read fresh and drop out of the stale set.
                    (map (lambda (u:string) (ref-RPS::XE_XI_FixUserFvtDebPenalizedIn fvt-id reward-dptf-id u members reward-rows)) batch)
                    (let
                        (
                            (remaining:integer (- (length stale) (length batch)))
                        )
                        (if (= (length stale) 0)
                            (format "Unstale-all: FVT {} lane {} — all present stakers up to date (injection-ready)." [fvt-id reward-dptf-id])
                            (format "Unstale-all: unstaled {} of {} stale staker(s) — {} remain{}." [(length batch) (length stale) remaining (if (= remaining 0) " (injection-ready)" ", keep paging")]))
                    )
                )
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
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>SWEEP-REVOKE patron anchor-id)
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV2} AQP-ANK)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL)
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
                        (ref-RPS::XE_XI_FvtSweepRecomputeChunk
                            (ref-SCR::UR_SCR|ScoreFvtLink sid)
                            (if (ref-SCR::UR_SCR|ScoreTriplet sid) (ref-SCR::UR_SCR|ScoreTripletId sid) sid)
                            boost-class-id
                            (ref-RPS::URH_FvtPresentUsers (ref-SCR::UR_SCR|ScoreFvtLink sid))))
                    score-ids)
                ;; 4. UNFREEZE
                (map (lambda (sid:string) (ref-AQP::XE_SetSweepInProgress (ref-SCR::UR_SCR|ScoreAqpoolLink sid) false)) score-ids)
                (format "Sweep-retired anchor {} (BoostClass {}): recomputed holders across {} employing score(s)." [anchor-id boost-class-id (length score-ids)])
            )
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
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>SWEEP-REVOKE patron anchor-id)
            (enforce (not (UR_FVT|SweepActive anchor-id)) "A sweep is already in progress for this anchor")
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV2} AQP-ANK)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL)
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
                            (total:integer (ref-RPS::URC_FvtSweepTotalPresent score-ids))
                        )
                        (WU_FvtSweepProgress anchor-id total 0 true)
                        (format "Sweep begun for anchor {} (BoostClass {}): swept-revoked; {} holder(s) to recompute across {} score(s) — page via CCp_SweepRecomputeChunk." [anchor-id boost-class-id total (length score-ids)])
                    )
                )
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
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>SWEEP-DRAIN patron anchor-id chunk)
            (let
                (
                    (ref-ANK:module{AcquisitionAnchorsV2} AQP-ANK)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL)
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
                                (n:integer (ref-RPS::XE_XI_FvtSweepRecomputeWindow score-ids boost-class-id offset win-hi))
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
    )
    (defun CC_UnstaleMyScores:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-ids:[string])
        @doc "User SELF-SERVICE deb-unstale: the caller refreshes THEIR OWN stale scores across `fvt-ids` — per \
            \ FVT, XI_FixUserFvtDeb settles the caller's pending at the OLD deb, refreshes each score deb to the \
            \ live Elite-DEB, and resyncs the FVT total-deb mirror. NON-penalized (self-service is the cheap path; \
            \ only inject-forced fixes bill the 2e penalty). Each member already fresh (or a true triplet) no-ops, \
            \ so passing a whole FVT only touches its stale members. Single-tx and bounded (a user's own FVT set is \
            \ small — no pagination needed). The UI finds the list via URC_FvtUserHasStaleMember per FVT the user \
            \ stakes. No fund movement (pending is banked, not paid). P|UEV_IMC + FVT|C>UNSTALE-MY-SCORES (owner)."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>UNSTALE-MY-SCORES patron)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;; fix ALL the caller's stale members across the listed FVTs (each fresh member no-ops)
                        (do
                            (map (lambda (fvt-id:string) (ref-RPS::XE_XI_FixUserFvtDeb patron fvt-id)) fvt-ids)
                            (UC_EmptyOc))
                        ;; GAS — the user pays for their own refresh
                        (URCi_UnstaleMyScores patron [(format "{}" [(length fvt-ids)])])
                    ]
                    []
                )
            )
        )
    )
    )
    (defun CC_Collect:object{IgnisCollectorV2.OutputCumulator}
        (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Collect reward DPTF — phases 0 → 5 — see canonical collect map above. UrStoa ≡ C_URV|Collect."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>COLLECT patron fvt-id score-entity-type score-entity-id reward-dptf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    ;;
                    (pool-id:string
                        (if (= score-entity-type CT_SCORE_ENTITY_TRIPLET)
                        (ref-SCR::UR_SCR|ScoreAqpoolLink (ref-SCR::UR_SCR|TripletSilverScoreId score-entity-id))
                        (ref-SCR::UR_SCR|ScoreAqpoolLink score-entity-id)
                    ))
                    (owner-konto:string (ref-RPS::UR_FVT|OwnerKonto fvt-id))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                )
                ;; DRIP the collected lane FIRST (checkpoint) so the farm pre-settle, the payout
                ;; (ref-RPS::URC_CollectClaimableRewards) and the PHASE-4 last-rps advance all reflect streamed rewards
                ;; vested up to `now`. No-op when the lane carries no live stream.
                (ref-RPS::XE_XI_ReleaseStream fvt-id reward-dptf-id)
                (if (= (ref-RPS::UR_FVT|FvtClass fvt-id) 0)
                    (ref-RPS::XE_XI_2|SettleMemberTier2 fvt-id score-entity-type score-entity-id reward-dptf-id)
                    true
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;===>PHASE 0=== (audit LP redesign / Stage 2b) farm ghost-TVL sync REMOVED — L_i is
                        ;; advanced at inject (split-at-inject); the pre-settle above still flushes parked pending.
                        ;;
                        ;;===>PHASE 1=== coin step 1 · C_Transmit URV|KONTO→account
                        ;; PRE payout via URC_CollectClaimableRewards inside XI (post phase 0, pre reset)
                        (ref-RPS::XE_XI_TransferRewardDptfFromVault patron pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
                        ;;
                        ;;===>PHASE 5=== coin step 5 · XI_URV|UpdateVaultSupply false
                        ;; ICO slot before phase 2 so URC reads same pre-reset state as UrStoa available-rewards let
                        (let
                            (
                                (payout:decimal
                                    (ref-RPS::URC_CollectClaimableRewards patron pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
                                )
                                (ar:decimal (ref-RPS::UR_FVT-RG|AvailableRewards fvt-id reward-dptf-id))
                                (new-ar:decimal (- ar payout))
                                ;; #10 Tier-1: decrement the member mini-vault too. Clamp at 0 for the global-sweep
                                ;; case (payout = global available ≥ member available), which zeroes the member vault.
                                (ma:decimal (ref-RPS::UR_FVT-MV|AvailableRewards fvt-id score-entity-id reward-dptf-id))
                                (new-ma:decimal
                                    (let
                                        (
                                            (m:decimal (- ma payout))
                                        )
                                        (if (< m 0.0) 0.0 m)
                                    )
                                )
                            )
                            ;; SECURE: granted by WU_RpsGlobal|AvailableRewards / WU_MemberVault|AvailableRewards (underlying W_).
                            (ref-RPS::XE_WU_RpsGlobal|AvailableRewards fvt-id reward-dptf-id new-ar)
                            (ref-RPS::XE_WU_MemberVault|AvailableRewards fvt-id score-entity-id reward-dptf-id new-ma)
                            (UC_EmptyOc)
                        )
                        ;;
                        ;;===>PHASE 2=== coin step 2 · XI_URV|ResetPendingRewards
                        (do
                            ;; SECURE: granted by WU_RpsUser|PendingRewards (underlying W_).
                            (ref-RPS::XE_WU_RpsUser|PendingRewards patron fvt-id score-entity-id reward-dptf-id 0.0)
                            (UC_EmptyOc)
                        )
                        ;;
                        ;;===>PHASE 3=== coin step 3 · XI_URV|UpdateUnclaimedCount false
                        (ref-RPS::XE_XI_BookCollectUnclaimed patron pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
                        ;;
                        ;;===>PHASE 4=== coin step 4 · XI_URV|UpdateUserRPS (farm: L_i; vault/treasury: G)
                        (do
                            ;; SECURE: granted by WU_RpsUser|LastRps (underlying W_).
                            (ref-RPS::XE_WU_RpsUser|LastRps patron fvt-id score-entity-id reward-dptf-id
                                (ref-RPS::URC_FvtTier1IndexRps fvt-id score-entity-id reward-dptf-id)
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
                        (ref-RPS::XE_XI_FixUserMemberDeb patron fvt-id score-entity-type score-entity-id)
                        ;;===>PHASE 7=== (M3 #12 2e) inject-forced-fix penalty: `count × RATE` NON-discountable IGNIS,
                        ;; then zero the count. Non-discount via gross-up (price = count×RATE / patron-discount → after
                        ;; the uniform prime-time discount it lands at exactly count×RATE). The reward paid is untouched;
                        ;; self-fixing (PHASE 6) is never penalized, so it stays the cheaper path. No-op when count = 0.
                        (let
                            (
                                (ffc:integer (ref-RPS::UR_FVT-FFC|Count fvt-id reward-dptf-id patron))
                            )
                            (if (<= ffc 0)
                                (UC_EmptyOc)
                                (let
                                    (
                                        (ref-DALOS:module{OuronetDalosV2} DALOS)
                                        (penalty:decimal (* (dec ffc) CT_FORCED_FIX_RATE))
                                    )
                                    (ref-RPS::XE_WU_FvtForcedFixCount|Zero fvt-id reward-dptf-id patron)
                                    (ref-IGNIS::UDC_ConstructOutputCumulator
                                        (/ penalty (ref-DALOS::URC_IgnisGasDiscount patron)) patron trigger []
                                    )
                                )
                            )
                        )
                        (ref-RPS::URCi_Collect fvt-id [fvt-id score-entity-id reward-dptf-id])
                    ]
                    []
                )
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
    (defun CC_TrueFungibleStakeFlow:object{IgnisCollectorV2.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal direction:bool)
        @doc "Core TF stake/unstake recipe. Phases 1 → 2 → 3 → 4 → 5 — see canonical map above."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>TRUE-FUNGIBLE-STAKE-FLOW pool-id owner-id beneficiary-id dptf-id amount direction)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    ;;
                    (settle-bundle:object{FVT|StakeSettleBundle}
                        (ref-RPS::URHC_BuildStakeSettleBundle pool-id beneficiary-id)
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
                        (ref-RPS::XE_XI_RpsPreScore beneficiary-id pool-id settle-bundle)
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
                        (ref-RPS::XE_XI_SyncFvtTotalDebMirrors (at "pre-member-debs" settle-bundle))
                        ;; PHASE 4.6 — Re-snapshot farm-triplet Level-1 weights (maintained Σ w-user divisor)
                        (ref-RPS::XE_XI_SyncTripletLaneWeights beneficiary-id (at "settle-plans" settle-bundle))
                        ;; PHASE 4.7 — Presence: stake→add, unstake→recompute (flip false on last withdrawal)
                        (ref-RPS::XE_XI_SyncFvtPresence beneficiary-id (at "distinct-fvts" settle-bundle) direction)
                        ;;
                        ;;===>PHASE 5===
                        ;; PHASE 5.1 — RPS unclaimed-count · UrStoa ≡ UpdateUnclaimedCount
                        (ref-RPS::XE_XI_BookStakeUnclaimedCounts beneficiary-id pool-id settle-bundle)
                        ;; PHASE 5.2 — RPS checkpoint last-rps · UrStoa ≡ UpdateUserRPS
                        (ref-RPS::XE_XI_CheckpointStakeRps beneficiary-id pool-id settle-bundle)
                    ]
                    []
                )
            )
        )
    )
    )
    ;;
    ;; --- OF stake/unstake recipe (Talos ×4 → CC_OrtoFungibleStakeFlow) ---
    ;;   No phase 2.2 — ANK anchors are DPTF / DPSF / DPNF only; OF custody does not refresh promile.
    (defun CC_OrtoFungibleStakeFlow:object{IgnisCollectorV2.OutputCumulator}
        (pool-id:string owner-id:string beneficiary-id:string dpof-id:string nonces:[integer] nonce-amounts:[decimal] direction:bool)
        @doc "Core OrtoFungible stake/unstake recipe. Phases 1 → 2 → 3 → 4 → 5 — see canonical map above. \
            \ OF: phase 1.3 and 3.x are N/A (comment-only in ICO list)."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability (FVT|C>ORTO-FUNGIBLE-STAKE-FLOW pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts direction)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    ;;
                    ;; M5: beneficiary-id is authoritative BOTH directions (stake and unstake). The caller supplies
                    ;; the real beneficiary on unstake too, so the exact (owner, beneficiary) tracker row is settled —
                    ;; no self-key derivation (which stranded non-self stakes). Sufficiency is enforced in the cap.
                    (settle-beneficiary:string beneficiary-id)
                    (settle-bundle:object{FVT|StakeSettleBundle}
                        (ref-RPS::URHC_BuildStakeSettleBundle pool-id settle-beneficiary)
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
                        (ref-RPS::XE_XI_RpsPreScore settle-beneficiary pool-id settle-bundle)
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
                        (ref-RPS::XE_XI_SyncFvtTotalDebMirrors (at "pre-member-debs" settle-bundle))
                        ;; PHASE 4.6 — Re-snapshot farm-triplet Level-1 weights (maintained Σ w-user divisor)
                        (ref-RPS::XE_XI_SyncTripletLaneWeights settle-beneficiary (at "settle-plans" settle-bundle))
                        ;; PHASE 4.7 — Presence: stake→add, unstake→recompute (flip false on last withdrawal)
                        (ref-RPS::XE_XI_SyncFvtPresence settle-beneficiary (at "distinct-fvts" settle-bundle) direction)
                        ;;
                        ;;===>PHASE 5===
                        ;; PHASE 5.1 — RPS unclaimed-count · UrStoa ≡ UpdateUnclaimedCount
                        (ref-RPS::XE_XI_BookStakeUnclaimedCounts settle-beneficiary pool-id settle-bundle)
                        ;; PHASE 5.2 — RPS checkpoint last-rps · UrStoa ≡ UpdateUserRPS
                        (ref-RPS::XE_XI_CheckpointStakeRps settle-beneficiary pool-id settle-bundle)
                    ]
                    []
                )
            )
        )
    )
    )
    ;;
    ;; --- DPDC collectable stake/unstake recipe (Talos ×4 → CC_CollectableStakeFlow; son=true DPSF / false DPNF) ---
    (defun CC_CollectableStakeFlow:object{IgnisCollectorV2.OutputCumulator}
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
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (P|UEV_IMC)
        (with-capability
            (FVT|C>COLLECTABLE-STAKE-FLOW
                pool-id owner-id beneficiary-id collectable-id son nonces nonce-amounts direction
            )
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV2} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV2} AQP-POOL)
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                    ;;
                    ;; M5: beneficiary-id is authoritative BOTH directions (see CC_OrtoFungibleStakeFlow). The caller
                    ;; supplies the real beneficiary on unstake, so the exact (owner, beneficiary) tracker + Ben rollup
                    ;; rows are settled — no self-key derivation. Sufficiency is enforced in the cap.
                    (settle-beneficiary:string beneficiary-id)
                    (settle-bundle:object{FVT|StakeSettleBundle}
                        (ref-RPS::URHC_BuildStakeSettleBundle pool-id settle-beneficiary)
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
                        (ref-RPS::XE_XI_RpsPreScore settle-beneficiary pool-id settle-bundle)
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
                        (ref-RPS::XE_XI_SyncFvtTotalDebMirrors (at "pre-member-debs" settle-bundle))
                        ;; PHASE 4.6 — Re-snapshot farm-triplet Level-1 weights (maintained Σ w-user divisor)
                        (ref-RPS::XE_XI_SyncTripletLaneWeights settle-beneficiary (at "settle-plans" settle-bundle))
                        ;; PHASE 4.7 — Presence: stake→add, unstake→recompute (flip false on last withdrawal)
                        (ref-RPS::XE_XI_SyncFvtPresence settle-beneficiary (at "distinct-fvts" settle-bundle) direction)
                        ;;
                        ;;===>PHASE 5===
                        ;; PHASE 5.1 — RPS unclaimed-count · UrStoa ≡ UpdateUnclaimedCount
                        (ref-RPS::XE_XI_BookStakeUnclaimedCounts settle-beneficiary pool-id settle-bundle)
                        ;; PHASE 5.2 — RPS checkpoint last-rps · UrStoa ≡ UpdateUserRPS
                        (ref-RPS::XE_XI_CheckpointStakeRps settle-beneficiary pool-id settle-bundle)
                    ]
                    []
                )
            )
        )
    )
    )

    ;;<=========================================================================>
    ;;{6}  REPL
    ;; [REPL] dry-run helpers (not on the interface)
    ;;
    ;; --- REPL dry-run (GOV|FVT_ADMIN; not on AcquisitionFarmsVaultsTreasuriesV2) ---
    ;; Until C_Issue / C_AddScoreEntity / C_AddRewardLink are implemented.
    (defun REPL_BootstrapVault:string
        (fvt-id:string owner-konto:string score-id:string reward-dptf-id:string)
        @doc "REPL-only: insert class-1 vault + enabled ScoreEntityLink (type 1) + reward-enabled RPS|Global."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (with-capability (GOV|FVT_ADMIN)
            (let
                (
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                )
                (with-capability (SECURE)
                    (WI_Fvt fvt-id
                        (UDC_FVT|Schema true true "|" false fvt-id)
                    )
                    (ref-RPS::XE_WI_FvtRewardAggregate fvt-id
                        (UDC_FVT|RewardAggregate 1 owner-konto true CT_MEMBERSHIP_MODE_BAR CT_SPLIT_MODE_NA 0.0 0.0 0.0 0.0 0 1 1 fvt-id)
                    )
                    (ref-RPS::XE_WI_ScoreEntityLink fvt-id score-id
                        (UDC_FVT|ScoreEntityLink CT_SCORE_ENTITY_SCORE true "|" 0.0 0.0 false 0.0 0.0 STREAM_EPOCH fvt-id score-id)
                    )
                    (ref-RPS::XE_WI_RpsGlobal fvt-id reward-dptf-id
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
    )
    (defun REPL_BootstrapTreasury:string
        (fvt-id:string owner-konto:string score-id:string reward-dptf-id:string)
        @doc "REPL-only: insert class-2 treasury + enabled ScoreEntityLink (type 1) + reward-enabled RPS|Global."
        (let
            (
                (ref-RPS:module{AcquisitionRewardPerShareV1} RPS)
            )
            (with-capability (GOV|FVT_ADMIN)
            (let
                (
                    (ref-SCR:module{AcquisitionScoresV2} AQP-SCORE)
                )
                (with-capability (SECURE)
                    (WI_Fvt fvt-id
                        (UDC_FVT|Schema true true "|" false fvt-id)
                    )
                    (ref-RPS::XE_WI_FvtRewardAggregate fvt-id
                        (UDC_FVT|RewardAggregate 2 owner-konto true CT_MEMBERSHIP_MODE_BAR CT_SPLIT_MODE_NA 0.0 0.0 0.0 0.0 0 1 1 fvt-id)
                    )
                    (ref-RPS::XE_WI_ScoreEntityLink fvt-id score-id
                        (UDC_FVT|ScoreEntityLink CT_SCORE_ENTITY_SCORE true "|" 0.0 0.0 false 0.0 0.0 STREAM_EPOCH fvt-id score-id)
                    )
                    (ref-RPS::XE_WI_RpsGlobal fvt-id reward-dptf-id
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


    ;;<=====================================================================>
    ;;  #75 FACADE — thin delegating wrappers onto the RPS reward engine
    (defun URC_CollectClaimableRewards:decimal (patron:string pool-id:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_CollectClaimableRewards patron pool-id fvt-id score-entity-type score-entity-id reward-dptf-id)
    )
    (defun URC_FvtUserStillPresent:bool (fvt-id:string user-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_FvtUserStillPresent fvt-id user-id)
    )
    (defun URC_InjectDenominator:decimal (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_InjectDenominator fvt-id)
    )
    (defun URC_LiveClaimable:decimal (user-id:string fvt-id:string pool-id:string score-entity-type:integer score-entity-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_LiveClaimable user-id fvt-id pool-id score-entity-type score-entity-id dptf-id)
    )
    (defun URC_MemberEffectiveCapture:decimal (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_MemberEffectiveCapture fvt-id score-entity-id)
    )
    (defun URC_MemberLevel2Weight:decimal (fvt-id:string score-entity-type:integer score-entity-id:string swpair:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_MemberLevel2Weight fvt-id score-entity-type score-entity-id swpair)
    )
    (defun URC_PoolEmployedScoresFvtStakeReady:bool (pool-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_PoolEmployedScoresFvtStakeReady pool-id)
    )
    (defun URC_ScoreEntityUserWeight:decimal (user-id:string fvt-id:string pool-id:string score-entity-type:integer score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_ScoreEntityUserWeight user-id fvt-id pool-id score-entity-type score-entity-id)
    )
    (defun URC_StakeScoreDeltaSum:decimal (pool-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_StakeScoreDeltaSum pool-id)
    )
    (defun URC_StreamStatus:object (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_StreamStatus fvt-id dptf-id)
    )
    (defun URC_UserTier1AvailableRewards:decimal (user-id:string fvt-id:string score-entity-id:string dptf-id:string deb-user:decimal)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URC_UserTier1AvailableRewards user-id fvt-id score-entity-id dptf-id deb-user)
    )
    (defun URCi_CollectFull:decimal (patron:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URCi_CollectFull patron fvt-id score-entity-type score-entity-id reward-dptf-id)
    )
    (defun URH_FvtEnabledScoreEntityIdsForFvt:[string] (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URH_FvtEnabledScoreEntityIdsForFvt fvt-id)
    )
    (defun URH_FvtPresentUsers:[string] (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URH_FvtPresentUsers fvt-id)
    )
    (defun URH_FvtStalePresentUsers:[string] (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.URH_FvtStalePresentUsers fvt-id)
    )
    (defun UR_ExternalOracle:bool ()
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_ExternalOracle)
    )
    (defun UR_FVT-FFC|Count:integer (fvt-id:string dptf-id:string user-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-FFC|Count fvt-id dptf-id user-id)
    )
    (defun UR_FVT-MV|AvailableRewards:decimal (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-MV|AvailableRewards fvt-id score-entity-id dptf-id)
    )
    (defun UR_FVT-QS|BronzeSplit:[integer] (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-QS|BronzeSplit fvt-id dptf-id)
    )
    (defun UR_FVT-QS|GoldSplit:[integer] (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-QS|GoldSplit fvt-id dptf-id)
    )
    (defun UR_FVT-QS|Mode:string (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-QS|Mode fvt-id dptf-id)
    )
    (defun UR_FVT-RG|AvailableRewards:decimal (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|AvailableRewards fvt-id dptf-id)
    )
    (defun UR_FVT-RG|CurrentRps:decimal (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|CurrentRps fvt-id dptf-id)
    )
    (defun UR_FVT-RG|RewardEnabled:bool (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|RewardEnabled fvt-id dptf-id)
    )
    (defun UR_FVT-RG|RewardKind:string (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|RewardKind fvt-id dptf-id)
    )
    (defun UR_FVT-RG|RoyaltyRewards:decimal (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|RoyaltyRewards fvt-id dptf-id)
    )
    (defun UR_FVT-RG|StreamCount:integer (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|StreamCount fvt-id dptf-id)
    )
    (defun UR_FVT-RG|StreamUnreleased:decimal (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|StreamUnreleased fvt-id dptf-id)
    )
    (defun UR_FVT-RG|UnclaimedCount:integer (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|UnclaimedCount fvt-id dptf-id)
    )
    (defun UR_FVT-RG|ZombieRewards:decimal (fvt-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RG|ZombieRewards fvt-id dptf-id)
    )
    (defun UR_FVT-RM|LastFarmRpsG:decimal (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RM|LastFarmRpsG fvt-id score-entity-id dptf-id)
    )
    (defun UR_FVT-RM|MemberDebRps:decimal (fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RM|MemberDebRps fvt-id score-entity-id dptf-id)
    )
    (defun UR_FVT-RU|LastRps:decimal (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RU|LastRps user-id fvt-id score-entity-id dptf-id)
    )
    (defun UR_FVT-RU|PendingRewards:decimal (user-id:string fvt-id:string score-entity-id:string dptf-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-RU|PendingRewards user-id fvt-id score-entity-id dptf-id)
    )
    (defun UR_FVT-SEL|CaptureUnits:decimal (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|CaptureUnits fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|CaptureWeight:decimal (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|CaptureWeight fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|Delegation:bool (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|Delegation fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|Enabled:bool (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|Enabled fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|GhostTvlWeight:decimal (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|GhostTvlWeight fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|OracleTs:time (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|OracleTs fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|ScoreEntityType:integer (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|ScoreEntityType fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|Swpair:string (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|Swpair fvt-id score-entity-id)
    )
    (defun UR_FVT-SEL|TotalLaneWeight:decimal (fvt-id:string score-entity-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-SEL|TotalLaneWeight fvt-id score-entity-id)
    )
    (defun UR_FVT-UP|IsPresent:bool (fvt-id:string ouronet-account:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT-UP|IsPresent fvt-id ouronet-account)
    )
    (defun UR_FVT|EnabledRewardCount:integer (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|EnabledRewardCount fvt-id)
    )
    (defun UR_FVT|FvtClass:integer (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|FvtClass fvt-id)
    )
    (defun UR_FVT|MembershipMode:string (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|MembershipMode fvt-id)
    )
    (defun UR_FVT|Mosaic:bool (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|Mosaic fvt-id)
    )
    (defun UR_FVT|OwnerKonto:string (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|OwnerKonto fvt-id)
    )
    (defun UR_FVT|SplitMode:string (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|SplitMode fvt-id)
    )
    (defun UR_FVT|TotalDebScore:decimal (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|TotalDebScore fvt-id)
    )
    (defun UR_FVT|TotalGhostTvlWeight:decimal (fvt-id:string)
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_FVT|TotalGhostTvlWeight fvt-id)
    )
    (defun UR_OracleValidity:integer ()
        @doc "Facade: delegates to the RPS reward engine (post-#75 split)."
        (RPS.UR_OracleValidity)
    )
)

(create-table P|T)
(create-table P|MT)
;;
(create-table FVT|T)                                            ;; Key = <FVT-ID>
(create-table FVT|T|VacateFreeze)                               ;; Key = <FVT-ID>
(create-table FVT|T|SweepProgress)                              ;; Key = <Anchor-ID>