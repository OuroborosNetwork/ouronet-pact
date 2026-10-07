;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 28
;; TS02-C3 -- the four mis-prefixed vacate entrypoints get their real band (+ the cascade)
;; =========================================================================================
;; THREE MODULES AND ONE NEW INTERFACE, IN LOAD ORDER. Send as ONE transaction: the V2
;; interface must exist before either citizen names it, and a half-applied cascade leaves two
;; modules pointing at an interface version their Talos no longer implements.
;;
;; -----------------------------------------------------------------------------------------
;; WHAT CHANGES
;; -----------------------------------------------------------------------------------------
;;     AQP-POOL|XB_VacateTrueFungible  ->  AQP-POOL|CC_VacateTrueFungible
;;     AQP-POOL|XB_VacateOrtoFungible  ->  AQP-POOL|CC_VacateOrtoFungible
;;     AQP-POOL|XB_VacateSemiFungible  ->  AQP-POOL|CC_VacateSemiFungible
;;     AQP-POOL|XB_VacateNonFungible   ->  AQP-POOL|CC_VacateNonFungible
;;
;; `XB_` means "protected; used inside this module AND by a forward module". Measured, NEITHER
;; half is true: nothing in TS02-C3 calls them (zero in-module callers, grepped tree-wide) and
;; no other module reaches them. They are ordinary Talos client entrypoints -- `(patron,
;; executor)`, `with-capability (P|TS)`, one core call, IGNIS on the patron, a format string --
;; structurally identical to the `CC_` wrappers beside them. They were named after their CALLEE
;; (`AQP-VCT::XB_Vacate*`, which IS legitimately `XB_`) instead of after their own band, and
;; they were the ONLY `X*`-named definitions in all eleven Talos modules.
;;
;; DOUBLED `CC_`, NOT `C_`, and that is a second thing the old prefix hid. The canon doubles a
;; client prefix when a heavy read is reached ANYWHERE in the execution tree, and `_heavy.py`
;; measures each of these four reaching FIVE: `URHC_VacateNonceOwnerRowsRaw`,
;; `URH_VacateCollectableInventory`, `URH_VacateCollectableNonceRows`, `URH_VacateOfInventory`,
;; `URH_VacateOfNonceRows`. A single `C_` would promise bounded cost the tree does not deliver.
;; The first draft of this round named them `C_` and the gate refused it.
;;
;; THE CONSEQUENCE WAS NOT COSMETIC. `_registry.py`'s entrypoint filter is
;; `^[A-Za-z0-9|_-]*\|C{1,2}p?_[A-Za-z0-9]+$`, which an `XB_` name cannot match -- so four LIVE
;; client operations were ABSENT from `OURONET-REGISTRY.json`, and therefore unreachable from
;; OuronetUI, unpriced in the IGNIS sheet, and invisible to every gate built on the registry.
;; They are reached today only by the REPL, through the modref, by their old name.
;;
;; -----------------------------------------------------------------------------------------
;; WHY AN INTERFACE BUMP, AND WHY THE MODULE IS AN UPGRADE
;; -----------------------------------------------------------------------------------------
;; A deployed interface is immutable, so renaming a member of `TalosStageTwo_ClientThreeV1` is
;; impossible -- hence `V2`, which must ship WITH the module that implements it. But TS02-C3
;; itself has been live since the V1 round, so its module half is an UPGRADE: the generator
;; strips its `(create-table P|T)` / `(create-table P|MT)` forms, because re-creating an
;; existing table aborts the whole transaction. The first draft of this round did not strip
;; them -- it used `full` mode -- and would have failed on the signer's dime.
;;
;; -----------------------------------------------------------------------------------------
;; THE CASCADE
;; -----------------------------------------------------------------------------------------
;; AQP-BOOT (13 modref sites) and DSP+ (3) are the only two modules holding
;; `module{TalosStageTwo_ClientThreeV1}`. Nothing else about either changes.
;;
;; AQP-BOOT REDEPLOYING IS SAFE MID-BOOTSTRAP. Its step guards read CHAIN STATE --
;; `UEV_BootStepState` against `UR_AA|AnchorsActive` and `DPDC.UR_SetClassesUsed` -- not
;; module-local progress, so a redeploy neither resets a completed step nor re-allows one.
;;
;; -----------------------------------------------------------------------------------------
;; AFTER THIS LANDS
;; -----------------------------------------------------------------------------------------
;; The registry gains four entrypoints, 423 -> 427. Run, in order:
;;     python3 REPL/tools/_registrylive.py --record
;;     python3 REPL/tools/_registry.py --probe
;; and the four appear in `OURONET-REGISTRY.json`, which is what makes them reachable from
;; OuronetUI at all. Until that is done the UI cannot see them and the ghost-value sweep will
;; not cover them.
;;
;; -----------------------------------------------------------------------------------------
;; SIGNING
;; -----------------------------------------------------------------------------------------
;; The module admin key for each, in the order they appear: TS02-C3's Talos admin,
;; `GOV|AQP_BOOT_ADMIN`, and DSP+'s. A deploy acquires module admin, not a client capability.
;;
;; VERIFY AFTER, as /local reads:
;;   (describe-module "ouronet-ns.TS02-C3")
;;       -> `interfaces` must list ouronet-ns.TalosStageTwo_ClientThreeV2
;;   (ouronet-ns.AQP-BOOT.UR_...) / any AQP-BOOT read
;;       -> must still answer; a modref type change alters no stored row
;; =========================================================================================

;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev2.py

(namespace "ouronet-ns")

;; ---- source: 2_CITIZEN/Stage_Z/../../1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact (new interface, whole; module as an upgrade -- create-table stripped)
(interface TalosStageTwo_ClientThreeV2
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
    (defun URCi_IssueGenericEarningVault:object{IgnisCollectorV3.OutputCumulator}
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
    (defun AQP-POOL|C_FinalizeVacate:string (patron:string executor:string pool-id:string))
    (defun AQP-POOL|CC_FullVacate:string (patron:string executor:string pool-id:string))
    (defun AQP-POOL|CCp_BatchVacateTrueFungible:string
        (patron:string pool-id:string dptf-id:string owner-ids:[string] beneficiary-ids:[string] amounts:[decimal]))
    (defun AQP-POOL|CCp_BatchVacateOrtoFungible:string
        (patron:string pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]]))
    (defun AQP-POOL|CCp_BatchVacateCollectables:string
        (patron:string pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]]))
    (defun AQP-POOL|CCp_BatchDrainTrueFungible:string
        (patron:string pool-id:string dptf-id:string owner-ids:[string] beneficiary-ids:[string] amounts:[decimal]))
    (defun AQP-POOL|CCp_BatchDrainOrtoFungible:string
        (patron:string pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]]))
    (defun AQP-POOL|CCp_BatchDrainCollectable:string
        (patron:string pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]]))
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

)
;;

(module TS02-C3 GOV
    @doc "TALOS Stage 2 Client Functiones Part 3 - Acquisition Pools Functions"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageTwo_ClientThreeV2)

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
    (defcap P|TS ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (defcap AQP|C>SYNC-TF-ANCHORS
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "AQP client event: pool-agnostic TF anchor repair. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>SYNC-SEMI-FUNGIBLE-ANCHORS
        (patron:string beneficiary-id:string dpsf-id:string)
        @doc "AQP client event: pool-agnostic DPSF anchor repair. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>SYNC-NON-FUNGIBLE-ANCHORS
        (patron:string beneficiary-id:string dpnf-id:string)
        @doc "AQP client event: pool-agnostic DPNF anchor repair. Composes P|TS only."
        @event
        (compose-capability (P|TS))
    )
    (defcap AQP|C>ABORT-VACATE
        (patron:string pool-id:string)
        @doc "AQP client event: clear vacate-in-progress (stake stays disabled). Composes P|TS only."
        @event
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
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
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
    (defun URCi_IssueGenericEarningVault:object{IgnisCollectorV3.OutputCumulator}
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
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-DSA:module{DsaV1} AQP-DSA)
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
                    (ref-DSA:module{DsaV1} AQP-DSA)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueLiquidityScore patron executor score-name precision lp-denominator mx-frozen mx-sleeping)
                )
                (format "Successfully issued Liquidity Score {} for owner {}." [score-name executor])
            )
        )
    )
    (defun AQP-SCR|C_IssueTrueFungibleScore:string
        (patron:string executor:string score-name:string precision:integer mx-frozen:decimal)
        @doc "Issues score-class 1 (DPTF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueTrueFungibleScore patron executor score-name precision mx-frozen)
                )
                (format "Successfully issued TrueFungible Score {} for owner {}." [score-name executor])
            )
        )
    )
    (defun AQP-SCR|C_IssueOrtoFungibleScore:string
        (patron:string executor:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Issues score-class 2 (DPOF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueOrtoFungibleScore patron executor score-name precision mx-sleeping mx-hibernated)
                )
                (format "Successfully issued OrtoFungible Score {} for owner {}." [score-name executor])
            )
        )
    )
    (defun AQP-SCR|C_IssueSemiFungibleScore:string
        (patron:string executor:string score-name:string precision:integer sft-equality:bool)
        @doc "Issues score-class 3 (DPSF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueSemiFungibleScore patron executor score-name precision sft-equality)
                )
                (format "Successfully issued SemiFungible Score {} for owner {}." [score-name executor])
            )
        )
    )
    (defun AQP-SCR|C_IssueNonFungibleScore:string
        (patron:string executor:string score-name:string precision:integer nft-score-model:integer)
        @doc "Issues score-class 4 (DPNF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueNonFungibleScore patron executor score-name precision nft-score-model)
                )
                (format "Successfully issued NonFungible Score {} for owner {}." [score-name executor])
            )
        )
    )
    (defun AQP-SCR|C_RotateScoreOwnership:string (patron:string executor:string executee:string score-id:string)
        @doc "Rotates score ownership in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_EnableDebBoost patron executor score-id))
                (format "Successfully enabled DEB boost for score {}." [score-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueTriplet:string
        (patron:string executor:string bronze-score-id:string silver-score-id:string golden-score-id:string)
        @doc "Issues SCR triplet bundle T|bronze|silver|golden and collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_TrueFungibleStakeFlow patron executor executee pool-id dptf-id amount false)
                )
                (UC_FormatUnstakeTrueFungibleResult pool-id executor executee dptf-id amount)
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
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[decimal] (ref-DPOF::UR_NoncesSupplies dpof-id nonces))
            )
            (with-capability (AQP|C>STAKE-ORTO-FUNGIBLE patron pool-id executor executee dpof-id nonces nonce-amounts)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[decimal] (ref-DPOF::UR_NoncesSupplies dpof-id nonces))
            )
            (with-capability (AQP|C>UNSTAKE-ORTO-FUNGIBLE patron pool-id executor executee dpof-id nonces nonce-amounts)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                (ref-DPDC:module{DpdcV2} DPDC)
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
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                (ref-DPDC:module{DpdcV2} DPDC)
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
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
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
    (defun AQP-POOL|C_FinalizeVacate:string
        (patron:string executor:string pool-id:string)
        @doc "Vacate-v2 FINALIZE (nuke) — after a pool has been fully drained via AQP-POOL|Cp_BatchDrain*, this \
            \ bulk-zeroes every employed score + bumps their vacate-generation (lazily invalidating all per-user \
            \ rows), then clears vacate-in-progress, re-enables stake, and unfreezes the pool's FVTs. Pool-owner + \
            \ nns==0 gated in VCT; IGNIS on patron. The commit-forward terminal step of a v2 drain campaign."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::C_FinalizeVacate patron executor pool-id))
                (format "Successfully finalized vacate on Pool {} — scores nuked, stake re-enabled." [pool-id])
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::CCp_BatchVacateTrueFungible pool-id dptf-id owner-ids beneficiary-ids amounts))
                (format "Batch-vacated {} TF leg(s) on Pool {} (asset {})." [(length owner-ids) pool-id dptf-id])
            )
        )
    )
    (defun AQP-POOL|CCp_BatchDrainTrueFungible:string
        (patron:string pool-id:string dptf-id:string owner-ids:[string] beneficiary-ids:[string] amounts:[decimal])
        @doc "Vacate-v2 FAST-DRAIN — one TF batch that returns assets + preserves rewards WITHOUT touching scores \
            \ and WITHOUT finalizing (cheaper than CCp_BatchVacateTrueFungible for large pools). First batch freezes \
            \ the pool + its FVTs; the pool stays frozen until AQP-POOL|C_FinalizeVacate nukes the scores once \
            \ empty. Owner enforced in VCT; IGNIS on patron. Commit-forward — CCp_BatchVacateTrueFungible is the \
            \ abortable path."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::CCp_BatchDrainTrueFungible pool-id dptf-id owner-ids beneficiary-ids amounts))
                (format "Fast-drained {} TF leg(s) on Pool {} (asset {}) — scores untouched, awaiting finalize."
                    [(length owner-ids) pool-id dptf-id])
            )
        )
    )
    (defun AQP-POOL|CCp_BatchDrainOrtoFungible:string
        (patron:string pool-id:string dpof-id:string owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]])
        @doc "Vacate-v2 FAST-DRAIN — one OF batch that returns nonces + preserves rewards WITHOUT touching scores \
            \ and WITHOUT finalizing. Amounts resolved on-chain from the tracker. First batch freezes the pool + \
            \ its FVTs; it stays frozen until AQP-POOL|C_FinalizeVacate nukes the scores once empty. Owner enforced \
            \ in VCT; IGNIS on patron. Commit-forward — CCp_BatchVacateOrtoFungible is the abortable path."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::CCp_BatchDrainOrtoFungible patron pool-id dpof-id owner-ids beneficiary-ids nonces-array))
                (format "Fast-drained {} OF leg(s) on Pool {} (asset {}) — scores untouched, awaiting finalize."
                    [(length owner-ids) pool-id dpof-id])
            )
        )
    )
    (defun AQP-POOL|CCp_BatchDrainCollectable:string
        (patron:string pool-id:string collectable-id:string son:bool owner-ids:[string] beneficiary-ids:[string] nonces-array:[[integer]] amounts-array:[[integer]])
        @doc "Vacate-v2 FAST-DRAIN — one DPSF (son=true) / DPNF (son=false) batch that returns nonces + preserves \
            \ rewards WITHOUT touching scores and WITHOUT finalizing. First batch freezes the pool + its FVTs; it \
            \ stays frozen until AQP-POOL|C_FinalizeVacate nukes the scores once empty. Owner enforced in VCT; \
            \ IGNIS on patron. Commit-forward — CCp_BatchVacateCollectables is the abortable path."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::CCp_BatchDrainCollectable pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array))
                (format "Fast-drained {} collectable leg(s) on Pool {} (asset {}, son {}) — scores untouched, awaiting finalize."
                    [(length owner-ids) pool-id collectable-id son])
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::CCp_BatchVacateCollectables pool-id collectable-id son owner-ids beneficiary-ids nonces-array amounts-array))
                (format "Batch-vacated {} collectable leg(s) on Pool {} (asset {}, son {})."
                    [(length owner-ids) pool-id collectable-id son])
            )
        )
    )
    (defun AQP-POOL|C_SyncTrueFungibleAnchors:string
        (patron:string executee:string dptf-id:string)
        @doc "Pool-agnostic TF anchor repair for beneficiary × dptf-id. Talos shell → AQP-POOL::C_SyncTrueFungibleAnchors."
        (with-capability (AQP|C>SYNC-TF-ANCHORS patron executee dptf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_ToggleRewardLink patron executor fvt-id reward-dptf-id enabled)
                )
                (format "Successfully toggled reward link {} on FVT {} to enabled={}." [reward-dptf-id fvt-id enabled])
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_Inject patron executor fvt-id reward-dptf-id amount)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully FRESH-injected {} {} into FVT {}." [amount reward-dptf-id fvt-id])
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
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-MTX-AQP:module{AqpMtxV1} MTX-AQP)
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
                    (ref-MTX-AQP:module{AqpMtxV1} MTX-AQP)
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
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
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
        @doc "Collects pending reward DPTF for patron on one score-entity from fvt-id; collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (bal-before:decimal (ref-DPTF::UR_AccountSupply reward-dptf-id patron))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_Collect patron executor fvt-id score-entity-type score-entity-id reward-dptf-id)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (let
                    (
                        (bal-after:decimal (ref-DPTF::UR_AccountSupply reward-dptf-id patron))
                        (payout:decimal (- bal-after bal-before))
                    )
                    (format "Successfully collected {} {} rewards from FVT {} for score-entity type {} id {}."
                        [payout reward-dptf-id fvt-id score-entity-type score-entity-id]
                    )
                )
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ref-DSA:module{DsaV1} AQP-DSA)
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
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DSA:module{DsaV1} AQP-DSA)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DSA::C_RecomputeCapture patron fvt-id score-entity-id)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Capture recomputed for agency {} on FVT {}." [score-entity-id fvt-id])
            )
        )
    )

    ;;<=========================================================================>
    ;;{6}  REPL
    ;;
    ;; --- REPL dry-run (P|TS client shell → AQP-FVT::REPL_BootstrapVault under GOV|FVT_ADMIN) ---
    (defun AQP-FVT|REPL_BootstrapVault:string
        (patron:string fvt-id:string owner-konto:string score-id:string reward-dptf-id:string)
        @doc "REPL-only Talos shell: composes P|TS for SCR XE IMC; forwards to AQP-FVT::REPL_BootstrapVault."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-FVT::REPL_BootstrapVault fvt-id owner-konto score-id reward-dptf-id)
            )
        )
    )
    (defun AQP-FVT|REPL_BootstrapTreasury:string
        (patron:string fvt-id:string owner-konto:string score-id:string reward-dptf-id:string)
        @doc "REPL-only Talos shell: class-2 treasury bootstrap for OF score pools."
        (with-capability (P|TS)
            (let
                (
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-FVT::REPL_BootstrapTreasury fvt-id owner-konto score-id reward-dptf-id)
            )
        )
    )


)

;; ---- source: 2_CITIZEN/Stage_Z/../5_VaultsMinter/04_AQP-BOOT.pact (module only -- its interface is already live)
(module AQP-BOOT GOV






    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements AcquisitionPoolBootV1)

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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (defconst BOOT|MX_FROZEN:decimal                    2.0)
    (defconst BOOT|MX_SLEEPING:decimal                  2.0)
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
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
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
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
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
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
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
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
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
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
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
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
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
        ;; | DHWonderCoach     | 3 DPSF    | DHWC-… dpsf-id           | SubsidiaryWonderCoach                                   |
        ;; | DHNosferatu       | 4 DPNF    | DHN-… dpnf-id            | SubsidiaryNosferatu                                     |
        ;; | DHBunnies         | 4 DPNF    | KBN-… dpnf-id            | SubsidiaryBunnies                                       |
        ;; | DHOuroLp          | 0 LP      | native LP id             | SilverSnakePower, BronzeSnakePower, GoldenSnakePower    |
        ;;
        ;; dh-asset-ids[0..5] — REPL examples (replace suffix with mainnet hash):
        ;;   0 "DHCD-98c486052a51"
        ;;   1 "DHB-98c486052a51"
        ;;   2 "E|DH-98c486052a51"
        ;;   3 "DHWC-98c486052a51"
        ;;   4 "DHN-98c486052a51"
        ;;   5 "KBN-98c486052a51"
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
        ;; dh-score-ids[0..8] — from Steps 4–5 (REPL shape below; on mainnet paste from output):
        ;;   [TheCodingDivision SubsidiaryCodingDivision Bloodshed SubsidiaryBloodshed
        ;;    DemiourgosShareholder DemiourgosSnakes SubsidiaryWonderCoach SubsidiaryNosferatu SubsidiaryBunnies]
        ;; ouro-triplet-score-ids[0..2] — from Step 6:
        ;;   [SilverSnakePower BronzeSnakePower GoldenSnakePower]
        ;;
        ;; REPL call (copy/paste; swap ids for mainnet):
        ;; (AQP-BOOT.C_Step7_CreatePoolsAndScores
        ;;   KST.ANHD
        ;;   ["DHCD-98c486052a51" "DHB-98c486052a51" "E|DH-98c486052a51" "DHWC-98c486052a51" "DHN-98c486052a51" "KBN-98c486052a51"]
        ;;   "W|SSTOA-OURO-WSTOA|LP-98c486052a51"
        ;;   [(U|DALOS.UDC_Makeid "DHCodingDivision") (U|DALOS.UDC_Makeid "DHBloodshed") (U|DALOS.UDC_Makeid "DHCompany")
        ;;    (U|DALOS.UDC_Makeid "DHWonderCoach") (U|DALOS.UDC_Makeid "DHNosferatu") (U|DALOS.UDC_Makeid "DHBunnies")]
        ;;   (U|DALOS.UDC_Makeid "DHOuroLp")
        ;;   [(U|DALOS.UDC_Makeid "TheCodingDivision") (U|DALOS.UDC_Makeid "SubsidiaryCodingDivision")
        ;;    (U|DALOS.UDC_Makeid "Bloodshed") (U|DALOS.UDC_Makeid "SubsidiaryBloodshed")
        ;;    (U|DALOS.UDC_Makeid "DemiourgosShareholder") (U|DALOS.UDC_Makeid "DemiourgosSnakes")
        ;;    (U|DALOS.UDC_Makeid "SubsidiaryWonderCoach") (U|DALOS.UDC_Makeid "SubsidiaryNosferatu") (U|DALOS.UDC_Makeid "SubsidiaryBunnies")]
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
                (enforce (= (length dh-score-ids) 9) "Step 7 expects dh-score-ids=[coding sub-coding bloodshed sub-bloodshed company-share company-snakes sub-wondercoach sub-nosferatu sub-bunnies].")
                (enforce (= (length ouro-triplet-score-ids) 3) "Step 7 expects ouro-triplet-score-ids=[silver bronze golden].")
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
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
                    (pool-coding:string (ref-U|DALOS::UDC_Makeid "DHCodingDivision"))
                    (pool-coding-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-coding))
                    (pool-bloodshed:string (ref-U|DALOS::UDC_Makeid "DHBloodshed"))
                    (pool-bloodshed-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-bloodshed))
                    (pool-company:string (ref-U|DALOS::UDC_Makeid "DHCompany"))
                    (pool-company-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-company))
                    (pool-wondercoach:string (ref-U|DALOS::UDC_Makeid "DHWonderCoach"))
                    (pool-wondercoach-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-wondercoach))
                    (pool-nosferatu:string (ref-U|DALOS::UDC_Makeid "DHNosferatu"))
                    (pool-nosferatu-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-nosferatu))
                    (pool-bunnies:string (ref-U|DALOS::UDC_Makeid "DHBunnies"))
                    (pool-bunnies-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-bunnies))
                    (pool-ouro-lp:string (ref-U|DALOS::UDC_Makeid "DHOuroLp"))
                    (pool-ouro-lp-owner:string (AQP-POOL.URC_AqpOwnerKonto pool-ouro-lp))
                    ;;
                    (score-coding:string (at 0 dh-score-ids))
                    (score-sub-coding:string (at 1 dh-score-ids))
                    (score-bloodshed:string (at 2 dh-score-ids))
                    (score-sub-bloodshed:string (at 3 dh-score-ids))
                    (score-company-share:string (at 4 dh-score-ids))
                    (score-company-snakes:string (at 5 dh-score-ids))
                    (score-sub-wondercoach:string (at 6 dh-score-ids))
                    (score-sub-nosferatu:string (at 7 dh-score-ids))
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
                ;; [5] DHNosferatu — aqp-class 4 (DPNF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-nosferatu-owner "DHNosferatu" asset-nosferatu 4)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-nosferatu-owner pool-nosferatu score-sub-nosferatu)
                ;; [6] DHBunnies — aqp-class 4 (DPNF)
                (ref-TS02-C3::AQP-POOL|C_Issue patron asset-bunnies-owner "DHBunnies" asset-bunnies 4)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bunnies-owner pool-bunnies score-sub-bunnies)
                ;; [7] DHOuroLp — aqp-class 0 (LP); triplet from Step 6 — see Step 6 ;; for OURO LP flow
                (ref-TS02-C3::AQP-POOL|C_Issue patron ouro-lp-asset-owner "DHOuroLp" ouro-lp-asset-id 0)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-ouro-lp-owner pool-ouro-lp score-silver)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-ouro-lp-owner pool-ouro-lp score-bronze)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-ouro-lp-owner pool-ouro-lp score-golden)
                ;;
                (format "AQP-BOOT Step 7 done. pool-ids=[coding={} bloodshed={} company={} wondercoach={} nosferatu={} bunnies={} ouro-lp={}]. ouro-lp-asset-id={}. score-slots-wired=12. NEXT=Step8:C_Step8_IssueFvtEntities."
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
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
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
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
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
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
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
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
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
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
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
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
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
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
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

;; ---- source: 2_CITIZEN/Stage_Z/03_DSP+.pact (module only -- its interface is already live)
(module DSP GOV






    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements DispenserV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DSP                                (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_DSP                                (keyset-ref-guard DSP|SC_KEY))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|DSP_ADMIN)))
    (defcap GOV|DSP_ADMIN ()
        (enforce-one
            "DSP Dispencer Admin not satisfed"
            [
                (enforce-guard GOV|MD_DSP)
                (enforce-guard GOV|SC_DSP)
            ]
        )
    )
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    ;;
    ;;  [Keys]
    (defun GOV|DSPKey ()                                (+ (CT_Namespace) ".dh_sc_dispenser-keyset"))
    (defun GOV|CSTKey ()                                (+ (CT_Namespace) ".dh_sc_custodians-keyset"))
    ;;
    ;;  [SC-Names]
    (defun GOV|DSP1|SC_NAME ()                          (at 0 ["Ѻ.hÜ5ĞÊÜεŞΓõè1Ă₳äàÄìãÓЦφLÕзЯŮμĞ₿мK6àŘуVćχδдзηφыβэÎχUHRêγBğΛ∇VŒižďЬШ£îOÜøE4ÖFSõЩЩAłκè1ččΨΦŻЖэч6Iчη₱ØćнúŒψУćÀyпãЗцÚäδÏÍtςřïçγț6γÎęôigFzÝûηы₿ÏЬüБэΞčмŃт₳ŘчjζsŠȚHъĘïЦ0"]))
    (defun GOV|CST1|SC_NAME ()                          (at 0 ["Ѻ.Щę7ãŽÓλ4ěПîЭđЮЫAďбQOχnиИДχѺNŽł6ПžιéИąĞuπЙůÞ1ęrПΔżæÍžăζàïαŮŘDzΘ€ЦBGÝŁЭЭςșúÜđŻõËŻκΩÎzŁÇÉΠмłÔÝÖθσ7₱в£μŻzéΘÚĂИüyćťξюWc2И7кςαTnÿЩE3MVTÀεPβafÖôoъBσÂбýжõÞ7ßzŁŞε0âłXâÃЛ"]))
    (defun GOV|DSP2|SC_NAME ()                          (+ "Σ" (drop 1 (GOV|DSP1|SC_NAME))))
    ;; STAGE TWO DISPENSING BUCKET -- OuroStageTwoDispensingBucket.
    ;; PLACEHOLDER. Issue the account with Deploy/2_Init/00_MANUAL_issue-s2-bucket.pact,
    ;; then paste the same Σ. string here. Flags: false / false / true.
    (defun GOV|DSP-S2|SC_NAME ()                        (at 0 ["Σ.i₿čУÕнЩťÛБoÛțmbюØДбgΣÞvhÉDτĞШU€ΛρÉycÇŒιЫWвфÓìÙõЙȚcąÅγXμSЛdăœρΣЫœąЛз4ěìvŹ₱OßeЛåγЬÿ5цůăÑœдżÛöÃŁτTĆĚŤйO9лцìŒUμvŤxBãĘΠÒÁõЪЖÌțȚeв¢jþψHtΣŹõÒqúΠğďßżpш2t3Şëχμι3DciüÏγλM"]))
    (defun GOV|CST2|SC_NAME ()                          (+ "Σ" (drop 1 (GOV|CST1|SC_NAME))))
    ;;
    ;;  [PBLs]
    ;; PLACEHOLDER -- the Stage Two bucket's public key, pasted at issuance.
    (defun GOV|DSP-S2|PBL ()                            (at 0 ["9G.Gj8lvMrcDLeieLBirwoqbGtgMlfxrC2840e62L93EfEyDuu8EsqxbMor9ofbK3B8Myv5Kgu3x4HhnukLFdHz8t4B604CEGayHseybKkvixzgvmk3LMpx5gM1yjxliprnnKfk7eyrzn5lrcHBwLvtcd7iM9sj2L85f6va68gns6hd3F5qzeABiKFiJ6vtpDxhGAeLwAov11BgMlbE9uHLv5eife0cathf0zhM25lmlbt6HpGL1wLgCIw035n9Bv7cocz5yF0Ent5os2v8fkJf7hsil7Lnon7FBvq6C9xu0fF641xDBMMC227AgdhLhDHB35t6dibw5tgmHdEiqhweiIlGj3eqMG3vrDBkin2oxDBLrcLjaiGdpLoLB7g5gHt0D2CJDIjzxn93hbF31sbux5B6Iin2K6CJgeo4cyu4a96xEpbE3yGG9mva7r48q4xtu652gm7EunHx58D2pI49b4KiEatxm0cdq1f5xpmqJt1IayBoiBAgwJcIrJC02yCzF1LxguMxcuwuo7i3gd3iHEuslC0gyGvxKCdm5L6pF9F04vhd05AJb3glLzk"]))
    (defun GOV|DSP|PBL ()                               (at 0 ["9G.o0n0iHmGhkch5aEqr0wcpEKpuqgGt5uvFapDLb94GwCbJvBga5H4xrFAx41CbMMH0M7AHmqFnrafceFmaHBfjsH51ggCxJmu5DMpK4jGg0rpogpD26r4yiykAIkaqDz61sHGewpxl1tly780ahKxbEB7uD8FlvA1nGppsttz3AhIhbxlhJ3BpI3Hehf5tCM6bfqF9o6ryb3bErqJwEDJmMGFC9HEeDiLKAtMgqaajzK2b0yg2sE0lJMp2K8I6sjfwnyhyL5vnycpMpeCgagdlnbMMMaA9trHLx4FxLym6KqCFAxCFwFHohfbcolG3u5wGo06M1fMBKpC64Mgm4584tH93Hpmop4tLpD7157GLo7mejJk8ryrA229K07D2hbhtanzCgdtjziBs9yqvHLq78EFEsD1fpEeD0pMhJeLEMEsqu8zf816cLErk4aDC22GnsC9774C59iaLFKkzKzh11xnAEalcpGcLf7aecGBHu5IABIGq8sEFa9Ahi5inermzrys3HcLpz2degMmAEy8hKsI83zvaCta8Ksimgn3qmv4r4jocMsIAwDeEfzE"]))
    (defun GOV|CST|PBL ()                               (at 0 ["9H.abeq3vvcwJp9gl2Kdt5xb7djJwdB35bCgkIaF3r0k38kBF6La1M6ci0ma2e5exMehsmwe1x3d6EpsIjxv95hAvc3uJweirnitcAAryxn9HaHJ1f0ya36BDfsrfaIBL4moIF3B8glb5pDBhta7pyxigEdt13ccEIKtCdyC6krMhB5iyqfEyB70zf5tjqn2xpDDzg9nA7auzzjxxtwLH80Lmdp4wAEcnqprGishhMLLefMnzDv9dFyM0n31fAcziHogCIM4kktFgydhHah7hmJurs3xCrGrs5qAEtjid0zioLHM58l8wogL2j0L9LIH21wI4lD1BlKq4445nos849CEzcm3DC9t67IH1r63pkgc9xFEGr8K6H3CCfg9aqDcApxaDuEomaKjEj6ft71gtEwbEJJmrAzfDolHrFfubcertjF2rE2wMywhv7HqIoHMCKEznMFCy2C6eyGyh1mIMeKJDDhwqIDIA5a2wvtt0HedKxmgDldafrrGdn5yDGHMexLFCrGv9aG50G82zIlE5z7cksfplf5taeiz8vlydDKmLaCcMgA7ne77hsbGHuu"]))

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
    (defcap P|DSP|CALLER ()
        true
    )
    (defcap P|DRG ()
        @doc "Dispenser Remote Governor Capability"
        true
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
        (with-capability (GOV|DSP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DSP_ADMIN)
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
        (with-capability (GOV|DSP_ADMIN)
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
        (with-capability (GOV|DSP_ADMIN)
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
                (ref-P|DALOS:module{OuronetPolicyV2} DALOS)
                (mg:guard (create-capability-guard (P|DSP|CALLER)))
            )
            (ref-P|DALOS::P|A_Add
                "DSP|RemoteDalosGov"
                (create-capability-guard (P|DRG))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    ;; STOA Accounts
    (defconst DSP|SC_STOA-NAME                          "k:78567097b68c98bf0c86a1938e60111a3bfc0ccadb858cc7f3630bc9da9dad99")
    (defconst CST|SC_STOA-NAME                          "k:309a1052856018a954d9692560934a3b8bb6fd0f283ab6eee5fc192b61c119a7")
    ;;
    ;;  Dispenser
    (defconst DSP|SC_KEY                                (GOV|DSPKey))
    (defconst DSP1|SC_NAME                              (GOV|DSP1|SC_NAME))
    (defconst DSP2|SC_NAME                              (GOV|DSP2|SC_NAME))
    (defconst DSP-S2|SC_NAME                            (GOV|DSP-S2|SC_NAME))
    ;;
    ;; ===================== THE STAGE TWO EMISSION ACCOUNT =====================
    ;; ONE LINE SWITCHES THE WHOLE EMISSION. Every leg of both Stage Two variants --
    ;; the one-shot AA_OuroMinterStageTwo, the flat leg, and all four inject legs --
    ;; reads S2-BUCKET|SC_NAME and nothing else, so the account moves in a single
    ;; edit rather than in nine.
    ;;
    ;; FLIPPED 2026-09-23 to DSP-S2|SC_NAME, the dedicated Stage Two bucket. It was
    ;; DSP1|SC_NAME -- the shared standard dispenser -- until the bucket was issued.
    ;;
    ;; WHY THE SWITCH IS WORTH MAKING. DSP1 is a STANDARD account, and the
    ;; transferability matrix makes Normal -> Normal unconditional -- so anyone
    ;; holding OURO can send it to the dispenser today, and nothing refuses. That
    ;; does not corrupt the emission, because every leg is FED its amount rather
    ;; than deriving it. But it does corrupt URC_StageTwoResidual, which derives
    ;; the four amounts from the balance -- and on a dedicated, unpollutable bucket
    ;; that reader becomes exactly correct, which is what lets the parallel legs be
    ;; built from a dirty read with no stored state and no enforce.
    ;; ==========================================================================
    (defconst S2-BUCKET|SC_NAME                         DSP-S2|SC_NAME)
    (defconst DSP|PBL                                   (GOV|DSP|PBL))
    ;;
    ;;  Custodians
    (defconst CST|SC_KEY                                (GOV|CSTKey))
    (defconst CST1|SC_NAME                              (GOV|CST1|SC_NAME))
    (defconst CST2|SC_NAME                              (GOV|CST2|SC_NAME))
    (defconst CST|PBL                                   (GOV|CST|PBL))
    (defconst GASLESS-PATRON                            (URC_Gassless))
    ;;
    ;; --- Stage Two emission sizing (URHC_StageTwoPlan's SEED, not the optimizer) ---
    ;; MEASURED, not chosen. REPL/Stage_02/[6.2.9] <<TX-BOOT-S2GAS>> puts the whole one-shot at
    ;; 911,546 - 966,256 gas on a fixture with a handful of stakers, and REPL/Kursan/AQP-scale-inject
    ;; puts ONE enforced-fresh inject leg at gas(n) = 199,096 + 5,189*n over its stale set. Four
    ;; inject legs plus mint/bulk-transfer/fuel/coil reconcile to the observed floor.
    (defconst S2-FIXED:integer 950000
        "The flat part of the emission: 4 x ~199k inject fixed cost + ~150k for mint, bulk \
       \ transfer, Auryndex fuel and the subsidiary coil. Taken at the TOP of the measured \
       \ band, because a preflight that UNDER-estimates sends the operator into a \
       \ transaction that aborts.")
    (defconst S2-GAS-PER-STALE:integer 6500
        "Per deb-stale staker, summed ACROSS ALL FOUR VAULTS -- they share one block. The \
       \ measured slope is 5,189; this carries the same ~25% margin AQP-FVT's \
       \ INJECT-FIX-GAS-PER-USER does, and is deliberately the SAME number, so the two \
       \ cannot quietly disagree about the cost of the same fix.")
    (defconst S2-ONE-TX-CEILING:integer 1600000
        "Recommend the one-shot below this, the parallel form above it. NOT 2,000,000: the \
       \ node gas meter is the real ceiling, chain state moved the measured figure by 6% \
       \ between two runs minutes apart, and a 20% reserve is what keeps a recommendation \
       \ from being a coin flip.")
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap DSP|GOV ()
        @doc "Governor Capability for the Dispenser Smart DALOS Account"
        true
    )
    (defcap DSP|S2-GOV ()
        @doc "Governor Capability for the Stage Two Dispensing Bucket Smart DALOS Account. \
            \ Composed only from this module -- a governor guard is an ownership proof."
        true
    )
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap DSP|STAGE-ONE-MINTER ()
        @event
        (compose-capability (GOV|DSP_ADMIN))
        (compose-capability (P|DRG))
    )
    ;; STAGE TWO -- one capability per operation, each composing DSP|S2-GOV and nothing wider,
    ;; so the emission's authority stops at its own bucket and the explorer can tell the four
    ;; operations apart. The inject caps carry their arguments, so the event names the vault.
    (defcap DSP|STAGE-TWO-MINTER ()
        @doc "The single-transaction Stage Two emission."
        @event
        (compose-capability (GOV|DSP_ADMIN))
        (compose-capability (DSP|S2-GOV))
    )
    (defcap DSP|STAGE-TWO-FLAT ()
        @doc "Phase 1 of the staged Stage Two emission -- mint, treasury, Auryndex fuel, coil. \
            \ This event without four matching DSP|STAGE-TWO-INJECT is a half-finished run."
        @event
        (compose-capability (GOV|DSP_ADMIN))
        (compose-capability (DSP|S2-GOV))
    )
    (defcap DSP|STAGE-TWO-INJECT (fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "One inject leg of the staged Stage Two emission."
        @event
        (compose-capability (GOV|DSP_ADMIN))
        (compose-capability (DSP|S2-GOV))
    )
    (defcap DSP|STAGE-TWO-INJECT-FINALIZE (fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "The paginated tail of one inject leg, after CCp_InjectFixChunk left zero stale."
        @event
        (compose-capability (GOV|DSP_ADMIN))
        (compose-capability (DSP|S2-GOV))
    )
    (defcap DSP|STOICISM-MINTER (stoicism-amounts:[decimal] stoicism-targets:[string])
        @event
        (compose-capability (GOV|DSP_ADMIN))
        (let
            (
                (l1:integer (length stoicism-amounts))
                (l2:integer (length stoicism-targets))
            )
            (enforce (= l1 l2) "Length of stoicism-amounts and stoicism-targets must be the same")
        )
        (compose-capability (P|DRG))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Namespace ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_KosonicAutostakeSplit:[decimal] (input:decimal ip:integer)
        (let
            (
                (one:decimal 0.0625)
                (ps:decimal (floor (* one input) ip))
                (cc:decimal (* ps 2.0))
                (pp:decimal (floor (* ps 2.5) ip))
                (tt:decimal (* ps 3.0))
                (sv:decimal (floor (* ps 3.5) ip))
                (aa:decimal (- input (fold (+) 0.0 [ps cc pp tt sv])))
            )
            [ps cc pp tt sv aa]
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_Gassless ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|DALOS|SC_NAME)
        )
    )
    (defun URC_DailyOURO ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (current-ouro-supply:decimal (ref-DPTF::UR_Supply ouro))
                (op:integer (ref-DPTF::UR_Decimals ouro))
                (maximum-theorethical-supply:decimal 10000000.0)
                (speed:decimal 10000.0)
            )
            (floor (/ (- maximum-theorethical-supply current-ouro-supply) speed) op)
        )
    )
    ;;
    (defun URHC_StageTwoPlan:object (fvt-ids:[string])
        @doc "PREFLIGHT for the Stage Two daily emission — read-only, call it via /local before \
            \ spending anything. Answers the only question that matters on the day: does today's \
            \ emission still fit in ONE transaction, or must it be run as the flat leg plus four \
            \ parallel injects. \
            \ \
            \ HEAVY (URH): it runs <URH_FvtStalePresentUsers> once per vault, which is the same \
            \ scan <CC_Inject> runs, so the count it returns is the exact set each inject would \
            \ have to fix. Four heavy scans is why this is a preflight and not something to call \
            \ inside a write path. \
            \ \
            \ RETURNS an object: \
            \   daily             the emission <A_OuroMinterStageTwo_Flat> would mint \
            \   split             the six shares, DESTINATION order, as UC_StageTwoEmissionSplit \
            \   subsidiary-auryn  the coil conversion at the CURRENT rate — INDICATIVE only, see below \
            \   stale             stale present users per vault, in the order fvt-ids was given \
            \   stale-total       their sum, which is what actually consumes the block \
            \   est-gas           S2-FIXED + S2-GAS-PER-STALE x stale-total \
            \   one-tx            est-gas < S2-ONE-TX-CEILING — a SEED for the UI, not a promise \
            \ \
            \ WHY subsidiary-auryn IS INDICATIVE: the one-shot reads <URC_RBT> AFTER fuelling the \
            \ Auryndex, and that fuel moves the pool's rate. Reading it here, before the fuel, \
            \ gives a near value and not the value. The number to inject is the one \
            \ <A_OuroMinterStageTwo_Flat> RETURNS, or <URC_StageTwoResidual> afterwards — never this one. \
            \ \
            \ AND `one-tx` IS A SEED. The node gas meter is the real ceiling and the UI must \
            \ simulate; an oversized transaction aborts atomically. See STAGE-TWO-EMISSION.md."
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                ;;
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (auryn:string (ref-DALOS::UR_AurynID))
                (op:integer (ref-DPTF::UR_Decimals ouro))
                (daily:decimal (URC_DailyOURO))
                (split:[decimal] (ref-U|DALOS::UC_StageTwoEmissionSplit daily op))
                (auryndex:string (at 0 (ref-DPTF::UR_RewardBearingToken auryn)))
            )
            (enforce (= (length fvt-ids) 4)
                "Stage Two expects fvt-ids x4: [custodians shareholders farm subsidiary]")
            (let
                (
                    (stale:[integer]
                        (map (lambda (f:string) (length (ref-FVT::URH_FvtStalePresentUsers f)))
                            fvt-ids))
                )
                (let
                    (
                        (stale-total:integer (fold (+) 0 stale))
                    )
                    {"daily"            : daily
                    ,"split"            : split
                    ,"subsidiary-auryn" : (ref-ATS::URC_RBT auryndex ouro (at 5 split))
                    ,"stale"            : stale
                    ,"stale-total"      : stale-total
                    ,"est-gas"          : (+ S2-FIXED (* S2-GAS-PER-STALE stale-total))
                    ,"one-tx"           : (< (+ S2-FIXED (* S2-GAS-PER-STALE stale-total))
                                             S2-ONE-TX-CEILING)}
                )
            )
        )
    )
    ;;
    (defun URC_StageTwoResidual:[decimal] ()
        @doc "RECOVERY reader for the parallel emission: the four inject amounts, derived from \
            \ what the dispenser is actually HOLDING. \
            \ \
            \ Use it when the UI has lost <A_OuroMinterStageTwo_Flat>'s return value — the \
            \ transaction landed but the response did not — or to verify before injecting. It is \
            \ the same idiom <A_KosonMinterStageOne_2of3> already uses: the dispenser balance IS \
            \ the carried state, so nothing has to be stored between transactions. \
            \ \
            \ After the flat leg the dispenser holds exactly 50% of the daily emission in OURO \
            \ (custodians 20 + shareholders 10 + farm 20) and the coiled AURYN. So the three OURO \
            \ shares are 40/20/40 OF THE RESIDUAL, exactly, and the subsidiary share is the whole \
            \ AURYN balance. \
            \ \
            \ RETURNS [custodians shareholders farm subsidiary-auryn] — the first three in OURO, \
            \ the fourth in AURYN. \
            \ \
            \ THE ONE RULE THIS DEPENDS ON: complete a run before starting the next. The ratios \
            \ are self-correcting across a RETRY of the same run — 40/20/40 of double is still \
            \ right — but running the flat leg for day two before day one's injects have landed \
            \ puts two emissions in one residual and the split would mis-allocate between them. \
            \ A dispenser that is not empty after a completed run is the alarm."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (auryn:string (ref-DALOS::UR_AurynID))
                (dispenser:string S2-BUCKET|SC_NAME)
            )
            (let
                (
                    (op:integer (ref-DPTF::UR_Decimals ouro))
                    (residual:decimal (ref-DPTF::UR_AccountSupply ouro dispenser))
                    (auryn-held:decimal (ref-DPTF::UR_AccountSupply auryn dispenser))
                )
                (let
                    (
                        (unit:decimal (floor (/ residual 5.0) op))
                    )
                    ;;40/20/40 of the residual, with the LAST OURO share absorbing the rounding
                    ;;remainder -- the same discipline UC_StageTwoEmissionSplit applies to the
                    ;;emission itself, so nothing is left stranded on the dispenser.
                    [(* 2.0 unit)
                     unit
                     (- residual (* 3.0 unit))
                     auryn-held]
                )
            )
        )
    )
    ;;
    (defun URC_DailyKOSON (iz-game-live:bool)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-AOZ:module{AgeOfZalmoxis} AOZ)
                ;;
                (PrimordialKosonID:string       (ref-AOZ::UR_PrimalTrueFungible 1))
                (op0:integer                    (ref-DPTF::UR_Decimals PrimordialKosonID))
                ;;
                (EsothericKosonID:string        (ref-AOZ::UR_PrimalTrueFungible 2))
                (current-EK-supply:decimal      (ref-DPTF::UR_Supply EsothericKosonID))
                (op1:integer                    (ref-DPTF::UR_Decimals EsothericKosonID))
                ;;
                (AncientKosonID:string          (ref-AOZ::UR_PrimalTrueFungible 3))
                (current-AK-supply:decimal      (ref-DPTF::UR_Supply AncientKosonID))
                (op2:integer                    (ref-DPTF::UR_Decimals AncientKosonID))
                ;;
                (esoteric-mts:decimal 16180339.887498948482045868343656)
                (esoteric-speed:decimal 7000.0)
                (ancient-mts:decimal 31415926.535897932384626433832795)
                (ancient-speed:decimal 8000.0)
                ;;
                (esoteric:decimal (floor (/ (- esoteric-mts current-EK-supply) esoteric-speed) op1))
                (ancient:decimal (floor (/ (- ancient-mts current-AK-supply) ancient-speed) op2))
                (primordial:decimal
                    (if iz-game-live
                        (floor (/ (+ esoteric ancient) 5.0) op0)
                        (floor (/ esoteric 5.0) op0)
                    )
                )
            )
            (if iz-game-live
                [primordial esoteric ancient]
                [primordial esoteric]
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_StoicismMinter (stoicism-amounts:[decimal] stoicism-targets:[string])
        (with-capability (DSP|STOICISM-MINTER stoicism-amounts stoicism-targets)
            (let
                (
                    (stoicism-id:string "STOICISM-hCNmIIxczuBs")
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (dispenser:string DSP1|SC_NAME)
                    (total-stoicism-amount:decimal (fold (+) 0.0 stoicism-amounts))
                    (l1:integer (length stoicism-amounts))
                    (l2:integer (length stoicism-targets))
                    (iz-empty:bool (and (= l1 0) (= l2 0)))
                )
                (if iz-empty
                    "No stoicism to mint or distribute"
                    [
                      ;;Mints Stoicism
                      (ref-TS01-C1::DPTF|C_Mint GASLESS-PATRON dispenser stoicism-id total-stoicism-amount false)
                      ;;Moves Stoicism to Targets
                      (ref-TS01-C1::DPTF|C_BulkTransfer GASLESS-PATRON dispenser stoicism-targets stoicism-id stoicism-amounts)
                    ]
                )
            )
        )
    )
    ;;
    (defun A_OuroMinterStageOne:[decimal] ()
        @doc "Mints the Stage One Daily OURO Emission"
        (with-capability (DSP|STAGE-ONE-MINTER)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (ref-TS01-C2:module{TalosStageOne_ClientTwoV2} TS01-C2)
                    (ouro:string (ref-DALOS::UR_OuroborosID))
                    (op:integer (ref-DPTF::UR_Decimals ouro))
                    (daily:decimal (URC_DailyOURO))
                    ;;
                    (split:[decimal] (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit daily op))
                    (s1-10p:decimal (at 0 split))
                    (s1-20p:decimal (at 1 split))
                    (s1-30p:decimal (at 2 split))
                    (s1-40p:decimal (at 3 split))
                    ;;
                    (treasury:string (ref-DALOS::GOV|DHV1|SC_NAME))
                    (validators:string CST1|SC_NAME)
                    (dispenser:string DSP1|SC_NAME)
                    ;;
                    (auryn:string (ref-DALOS::UR_AurynID))
                    (elite-auryn:string (ref-DALOS::UR_EliteAurynID))
                    (auryndex:string (at 0 (ref-DPTF::UR_RewardBearingToken auryn)))
                    (elite-auryndex:string (at 0 (ref-DPTF::UR_RewardBearingToken elite-auryn)))
                )
                ;;Mints whole daily on Dispencer
                (ref-TS01-C1::DPTF|C_Mint GASLESS-PATRON dispenser ouro daily false)
                ;;Moves 10% To Treasury and 20% to Validators
                (ref-TS01-C1::DPTF|C_BulkTransfer GASLESS-PATRON dispenser [treasury validators] ouro [s1-10p s1-20p])
                ;;Uses 30% to Fuel the Auryndex
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser auryndex ouro s1-30p)
                ;;Uses 40% to Coil to Auryn and then use Auryn to Fuel Elite-Auryndex
                (let
                    (
                        (c-rbt-amount:decimal (ref-ATS::URC_RBT auryndex ouro s1-40p))
                    )
                    (ref-TS01-C2::ATS|C_Coil GASLESS-PATRON dispenser auryndex ouro s1-40p)
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser elite-auryndex auryn c-rbt-amount)
                    ;; Interface contract is A_OuroMinterStageOne:[decimal] — return the split amounts
                    ;; [daily 10% 20% 30% 40%] (module defuns cannot print, so no in-body log strings).
                    [daily s1-10p s1-20p s1-30p s1-40p]
                )
            )
        )
    )
    ;;
    (defun AA_OuroMinterStageTwo:[decimal] (fvt-ids:[string])
        @doc "Mints the Stage Two Daily OURO Emission — the full six-way split that replaces Stage \
            \ One's 10/20/30/40. HEAVY (AA_): four CC_Inject legs, each of which scans the FVT's \
            \ present users, so cost scales with staker count and NOT with a constant. The doubled \
            \ prefix was not chosen — _heavy.py reported it: `DSP.A_OuroMinterStageTwo reaches \
            \ RPS.URH_FvtEnabledScoreEntityIdsForFvt`. Stage One is a flat A_ at ~135k gas; this is \
            \ structurally a different animal and is expected to cost far more. \
            \ One's 10/20/30/40 once SFTs, NFTs and stake-pools exist. \
            \ \
            \ INPUT `fvt-ids` — FOUR ids, BY POSITION. They are passed rather than hardcoded because \
            \ every AQP entity id carries the block hash of the transaction that minted it \
            \ (U|DALOS::UDC_Makeid = <name>-<first 12 of prev-block-hash>), so they cannot be known \
            \ when this module is written and cannot be recomputed afterwards. Everything this \
            \ function CAN derive it does derive — OURO, Auryn, the Auryndex, the treasury and the \
            \ dispenser all come from DALOS readers, exactly as Stage One does: \
            \   [0] CustodiansVault        — the DSA delegation vault (AQP-BOOT Step 13) \
            \   [1] CompanySharesTreasury  — shareholders (Step 8) \
            \   [2] OuroLpFarm             — Ouroboros liquidity farming (Step 8) \
            \   [3] SubsidiaryTreasury     — Demiourgos NFT staking (Step 8) \
            \ \
            \ SPLIT of the whole daily emission: 20% Custodians · 10% Treasury · 10% Shareholders · \
            \ 20% LP Farming · 20% Autostaking (Auryndex) · 20% Subsidiary. \
            \ \
            \ THE SUBSIDIARY LEG IS COILED, not injected as OURO: SubsidiaryTreasury's reward link is \
            \ AURYN (Step 12), so OURO cannot be injected into it at all. The 20% is coiled OURO→Auryn \
            \ through the Auryndex and the Auryn is injected — the same idiom Stage One already uses \
            \ to reach the Elite-Auryndex. \
            \ \
            \ GASLESS, AND THE EMISSION SITS ON THE DISPENSER -- which it could not, until Band 3. \
            \ IGNIS is waived for exactly one account: \
            \ 02_IGNIS.pact XE_CollectIgnis reads `(= patron (DALOS::GOV|DALOS|SC_NAME))` and skips collection \
            \ when true -- the owner-confirmed single hardcoded gasless payer, which is what \
            \ GASLESS-PATRON binds to. Stage One can pass it as `patron` while the tokens move from \
            \ the dispenser, because C_Mint / C_BulkTransfer / ATS|C_Fuel / ATS|C_Coil all take patron \
            \ AND a separate source account. CC_Inject does NOT: it debits the patron itself \
            \ (04_RPS.pact XI_FvtInjectCore -> C_Transfer token PATRON AQP|SC_NAME). So to inject \
            \ gaslessly the emission had to be MINTED TO the gasless patron -- the dispenser could not \
            \ hold it. Band 3 (2026-09-20) gave inject a named executor, so the roles separate the way \
            \ every other leg here already did: GASLESS-PATRON pays, `dispenser` acts. The emission is \
            \ back on the dispenser, where it belongs. \
            \ \
            \ GAS, MEASURED 2026-09-20: ~910k-970k, i.e. roughly HALF of a 2M block, against Stage \
            \ One's ~135k. Seven times the cost for one transaction. \
            \ \
            \ AND THAT IS A FLOOR, NOT A CEILING. Four of the six legs are CC_Inject, the HEAVY \
            \ enforced-fresh variant: each SCANS the FVT's present users and fixes every stale one, \
            \ so cost scales with STAKER COUNT. The measurement above comes from a fixture with a \
            \ handful of stakers. On a chain with real depth this transaction does not fit, and the \
            \ two measurements taken minutes apart already differ by 6% (911,546 in the boot suite, \
            \ 966,256 standalone) purely from chain state. \
            \ \
            \ RE-MEASURED 2026-09-20 after the patron/executor refactor converted 52 entrypoints: \
            \ 911,547 -- ONE GAS more than before it. Read that for what it is. This function's \
            \ path (C_Mint, C_BulkTransfer, CC_Inject x4, C_Coil) was already converted in Band 3; \
            \ the Band 1 work that followed touched CONFIGURATION and ADMIN entrypoints the \
            \ emission never calls. So the figure is a REGRESSION CHECK that nothing on the money \
            \ path moved -- not evidence that adding an executor is free. \
            \ \
            \ The documented spike fallback is the MTX|n|C_Inject defpact -- and until 2026-09-20 \
            \ that fallback was FICTION for this function: the defpact hardcoded `XB_FvtInject \
            \ patron patron`, so it could only run when the gas payer was also the token source, \
            \ which is precisely the shape this minter does NOT use. It now takes an `injector`, \
            \ proven by <<TX-MTX-SPONSOR>>. Plan for the daily \
            \ emission to become a SEQUENCE rather than one transaction before the Custodians vault \
            \ has depth -- not after. Pinned by <<TX-BOOT-S2GAS>> as a BAND (fits a block / is not \
            \ suspiciously cheap), because an exact pin would be noise at this variance and a \
            \ cheaper emission is a BROKEN one, not an improvement. \
            \ \
            \ RETURNS [daily custodians treasury shareholders farm autostake subsidiary-auryn]."
        (with-capability (DSP|STAGE-TWO-MINTER)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (ref-TS01-C2:module{TalosStageOne_ClientTwoV2} TS01-C2)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                    (ouro:string (ref-DALOS::UR_OuroborosID))
                    (op:integer (ref-DPTF::UR_Decimals ouro))
                    (daily:decimal (URC_DailyOURO))
                    ;;
                    (split:[decimal] (ref-U|DALOS::UC_StageTwoEmissionSplit daily op))
                    (s2-custodians:decimal (at 0 split))
                    (s2-treasury:decimal (at 1 split))
                    (s2-shareholders:decimal (at 2 split))
                    (s2-farm:decimal (at 3 split))
                    (s2-autostake:decimal (at 4 split))
                    (s2-subsidiary:decimal (at 5 split))
                    ;;
                    (treasury:string (ref-DALOS::GOV|DHV1|SC_NAME))
                    (dispenser:string S2-BUCKET|SC_NAME)  ;;holds the emission; the EXECUTOR of every leg
                    ;;
                    (auryn:string (ref-DALOS::UR_AurynID))
                    (auryndex:string (at 0 (ref-DPTF::UR_RewardBearingToken auryn)))
                )
                (enforce (= (length fvt-ids) 4)
                    "Stage Two expects fvt-ids x4: [custodians shareholders farm subsidiary]")
                ;;1. Mint the whole daily emission on the Dispenser
                (ref-TS01-C1::DPTF|C_Mint GASLESS-PATRON dispenser ouro daily false)
                ;;2. 10% to the Demiourgos Treasury, as pure OURO
                (ref-TS01-C1::DPTF|C_BulkTransfer GASLESS-PATRON dispenser [treasury] ouro [s2-treasury])
                ;;3. 20% into the Custodians vault. Injected as OURO; the multiplet ladder pays each
                ;;   staker OURO, Auryn or Elite-Auryn according to their score quality.
                (ref-TS02-C3::AQP-FVT|CC_Inject GASLESS-PATRON dispenser (at 0 fvt-ids) ouro s2-custodians)
                ;;4. 10% to shareholders. Its reward link IS Ouroboros, so a direct OURO inject.
                (ref-TS02-C3::AQP-FVT|CC_Inject GASLESS-PATRON dispenser (at 1 fvt-ids) ouro s2-shareholders)
                ;;5. 20% into Ouroboros liquidity farming — OURO in, triplet rules out.
                (ref-TS02-C3::AQP-FVT|CC_Inject GASLESS-PATRON dispenser (at 2 fvt-ids) ouro s2-farm)
                ;;6. 20% fuels the Auryndex directly
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser auryndex ouro s2-autostake)
                ;;7. 20% coiled OURO->Auryn, then injected as AURYN into the Subsidiary treasury
                (let
                    (
                        (subsidiary-auryn:decimal (ref-ATS::URC_RBT auryndex ouro s2-subsidiary))
                    )
                    (ref-TS01-C2::ATS|C_Coil GASLESS-PATRON dispenser auryndex ouro s2-subsidiary)
                    (ref-TS02-C3::AQP-FVT|CC_Inject GASLESS-PATRON dispenser (at 3 fvt-ids) auryn subsidiary-auryn)
                    [daily s2-custodians s2-treasury s2-shareholders s2-farm s2-autostake subsidiary-auryn]
                )
            )
        )
    )
    ;;
    (defun A_OuroMinterStageTwo_Flat:[decimal] ()
        @doc "PHASE 1 of the PARALLEL Stage Two emission: every leg that does NOT scale. Mint the \
            \ whole daily emission onto the dispenser, pay the Demiourgos treasury, fuel the \
            \ Auryndex, and coil the subsidiary share OURO->AURYN. \
            \ \
            \ TAKES NO ARGUMENTS, deliberately: not one of these four legs touches an FVT, so the \
            \ vault ids are not needed until the inject legs. Feeding ids to a function that \
            \ cannot use them invites the day somebody feeds the WRONG ones and nothing complains. \
            \ \
            \ FLAT `A_`, not `AA_`: no heavy read is reachable from here. That is the entire point \
            \ of the split -- A_OuroMinterStageOne has exactly this leg set and costs ~135k. \
            \ \
            \ AFTER IT, THE DISPENSER HOLDS exactly 50% of the daily emission in OURO (custodians \
            \ 20 + shareholders 10 + farm 20) and the coiled AURYN, and nothing else is owed. Run \
            \ the four inject legs next, IN ANY ORDER -- they are fed their amounts rather than \
            \ chaining off each other, so they are order-independent and may be submitted in \
            \ parallel. If this return value is lost, <URC_StageTwoResidual> recovers the four \
            \ amounts from the dispenser's balances. \
            \ \
            \ WHY THE SPLIT CANNOT RECOMPUTE ITSELF LATER: URC_DailyOURO reads the OURO SUPPLY, \
            \ and leg 1 mints into that supply. A second transaction that recomputes the daily \
            \ gets a smaller number and its shares no longer sum to what was minted. So the \
            \ emission is computed ONCE, here, and the dispenser's balance carries it -- the same \
            \ idiom A_KosonMinterStageOne_2of3 uses, for the same reason. \
            \ \
            \ ORDER IS LOAD-BEARING inside this function: URC_RBT is read AFTER the Auryndex fuel \
            \ and BEFORE the coil, exactly as the one-shot does, because the fuel moves the rate \
            \ the conversion is quoted at. \
            \ \
            \ RETURNS [daily custodians shareholders farm subsidiary-auryn] -- the daily for the \
            \ record, then the FOUR amounts the inject legs take, in vault order."
        (with-capability (DSP|STAGE-TWO-FLAT)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (ref-TS01-C2:module{TalosStageOne_ClientTwoV2} TS01-C2)
                    (ouro:string (ref-DALOS::UR_OuroborosID))
                    (op:integer (ref-DPTF::UR_Decimals ouro))
                    (daily:decimal (URC_DailyOURO))
                    ;;
                    (split:[decimal] (ref-U|DALOS::UC_StageTwoEmissionSplit daily op))
                    (s2-custodians:decimal (at 0 split))
                    (s2-treasury:decimal (at 1 split))
                    (s2-shareholders:decimal (at 2 split))
                    (s2-farm:decimal (at 3 split))
                    (s2-autostake:decimal (at 4 split))
                    (s2-subsidiary:decimal (at 5 split))
                    ;;
                    (treasury:string (ref-DALOS::GOV|DHV1|SC_NAME))
                    (dispenser:string S2-BUCKET|SC_NAME)
                    ;;
                    (auryn:string (ref-DALOS::UR_AurynID))
                    (auryndex:string (at 0 (ref-DPTF::UR_RewardBearingToken auryn)))
                )
                ;;1. Mint the whole daily emission on the Dispenser
                (ref-TS01-C1::DPTF|C_Mint GASLESS-PATRON dispenser ouro daily false)
                ;;2. 10% to the Demiourgos Treasury, as pure OURO
                (ref-TS01-C1::DPTF|C_BulkTransfer GASLESS-PATRON dispenser [treasury] ouro [s2-treasury])
                ;;3. 20% fuels the Auryndex directly
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser auryndex ouro s2-autostake)
                ;;4. 20% coiled OURO->Auryn. The rate is read AFTER the fuel, as in the one-shot.
                (let
                    (
                        (subsidiary-auryn:decimal (ref-ATS::URC_RBT auryndex ouro s2-subsidiary))
                    )
                    (ref-TS01-C2::ATS|C_Coil GASLESS-PATRON dispenser auryndex ouro s2-subsidiary)
                    [daily s2-custodians s2-shareholders s2-farm subsidiary-auryn]
                )
            )
        )
    )
    ;;
    (defun AA_OuroMinterStageTwo_InjectLeg:string
        (fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "PHASE 2 of the PARALLEL Stage Two emission: ONE inject leg, run four times. \
            \ \
            \ Call it once per vault with the amount <A_OuroMinterStageTwo_Flat> returned (or \
            \ <URC_StageTwoResidual> recovered): custodians/shareholders/farm in OURO, subsidiary \
            \ in AURYN. The four calls are ORDER-INDEPENDENT and may be submitted in parallel -- \
            \ each is fed its amount rather than deriving it from what the previous leg left. \
            \ \
            \ The safety here is intrinsic rather than asserted: the dispenser cannot spend what \
            \ it does not hold, so an over-stated amount ABORTS instead of mis-paying. \
            \ \
            \ HEAVY (AA_): AQP-FVT|CC_Inject is the enforced-fresh variant. It scans the FVT's \
            \ present users and fixes every deb-stale one so the divisor is live before the money \
            \ moves, which is exactly the work that scales and exactly why this leg was split out. \
            \ When ONE vault's stale set alone will not fit a transaction, page \
            \ AQP-FVT|CCp_InjectFixChunk until nothing is stale and finish with \
            \ <AA_OuroMinterStageTwo_InjectLegFinalize>. \
            \ \
            \ GASLESS-PATRON pays, the dispenser acts."
        (with-capability (DSP|STAGE-TWO-INJECT fvt-id reward-dptf-id amount)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                )
                (ref-TS02-C3::AQP-FVT|CC_Inject
                    GASLESS-PATRON S2-BUCKET|SC_NAME fvt-id reward-dptf-id amount)
            )
        )
    )
    ;;
    (defun AA_OuroMinterStageTwo_InjectLegFinalize:string
        (fvt-id:string reward-dptf-id:string amount:decimal)
        @doc "PHASE 3 tail: the same leg as <AA_OuroMinterStageTwo_InjectLeg>, for a vault whose \
            \ stale set did not fit one transaction. \
            \ \
            \ Run AQP-FVT|CCp_InjectFixChunk with a simulated chunk until the report says zero \
            \ remain, THEN call this. AQP-FVT|CC_InjectFinalize enforces zero-stale at inject, so \
            \ the outcome is identical to the single-transaction inject -- it is the same money \
            \ into the same lane on the same fresh divisor, and if a page was missed it refuses \
            \ rather than injecting on a stale one. \
            \ \
            \ The other two routes for the same situation are AQP-FVT|CCp_UnstaleAll (mass-unstale \
            \ without injecting, then a now-light inject) and MTX-AQP|2|CC_Inject (the 2-step \
            \ defpact). See STAGE-TWO-EMISSION.md for which to reach for."
        (with-capability (DSP|STAGE-TWO-INJECT-FINALIZE fvt-id reward-dptf-id amount)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV2} TS02-C3)
                )
                (ref-TS02-C3::AQP-FVT|CC_InjectFinalize
                    GASLESS-PATRON S2-BUCKET|SC_NAME fvt-id reward-dptf-id amount)
            )
        )
    )
    ;;
    (defun A_KosonMinterStageOne ()
        @doc "Executes the daily Koson Emission, in a single Tx"
        (with-capability (DSP|STAGE-ONE-MINTER)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (ref-AOZ:module{AgeOfZalmoxis} AOZ)
                    ;;
                    (PrimordialKosonID:string      (ref-AOZ::UR_PrimalTrueFungible 1))
                    (EsothericKosonID:string       (ref-AOZ::UR_PrimalTrueFungible 2))
                    (op0:integer (ref-DPTF::UR_Decimals PrimordialKosonID))
                    (op1:integer (ref-DPTF::UR_Decimals EsothericKosonID))
                    ;;
                    (daily:[decimal] (URC_DailyKOSON false))
                    (ps:[decimal] (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit (at 0 daily) op0))
                    (ps10:decimal (at 0 ps))
                    (ps20:decimal (at 1 ps))
                    (ps40:decimal (at 3 ps))
                    ;;
                    (standard-treasury:string (ref-DALOS::GOV|DHV1|SC_NAME))
                    (smart-treasury:string (ref-DALOS::GOV|DHV2|SC_NAME))
                    (validators:string CST1|SC_NAME)
                    (dispenser:string DSP1|SC_NAME)
                )
                ;;Mints Primordial Koson and Esoteric Koson Amounts
                (ref-TS01-C1::DPTF|C_Mint GASLESS-PATRON dispenser PrimordialKosonID (at 0 daily) false)
                (ref-TS01-C1::DPTF|C_Mint GASLESS-PATRON dispenser EsothericKosonID (at 1 daily) false)
                ;;Moves Primordial Kosons: 10% To Standard-Treasury, 20% to Smart-Treasury, 40% to Custodians(Validators)
                ;;Leaving 30% of the Primordial Kosons to <dispenser>
                ;;
                ;;BUG FIX 2026-09-21: THESE TWO LINES WERE MISSING. The comment above has always
                ;;promised the 10/20/40 split and this single-transaction variant never performed
                ;;it -- while its three-part sibling A_KosonMinterStageOne_1of3, thirty lines
                ;;below, does exactly this with identical bindings. `ps10`, `ps20`, `ps40`,
                ;;`standard-treasury`, `smart-treasury` and `validators` were all computed here
                ;;and never read; those six dead bindings were the only visible trace, surfaced by
                ;;`_deadbind.py --twins`.
                ;;
                ;;IT WAS NOT LATENT. This entrypoint is live and was exercised on every gate run
                ;;by Stage_01/[6.8]_Dispenser.repl -- which called it, printed a gas figure and
                ;;asserted NOTHING, so it could only ever distinguish "did not throw" from
                ;;"threw". Measured before the fix: the three recipients received 0.0 against an
                ;;expected 46.09 / 92.17 / 184.35.
                ;;
                ;;And the loss compounds rather than merely stalling, because the `let` directly
                ;;below reads `daily-primordial-left` -- the dispenser's REMAINING balance, which
                ;;this comment documents as the 30% -- and splits it six ways into the autostake
                ;;pools. With the transfers missing that balance is 100%, so the pools drew 3.33x
                ;;their intended share every day this path ran, and the treasuries and validators
                ;;drew nothing. Pinned by <<DSP-G1>>.
                (ref-TS01-C1::DPTF|C_BulkTransfer GASLESS-PATRON dispenser [standard-treasury validators] PrimordialKosonID [ps10 ps40])
                (ref-TS01-C1::DPTF|C_Transfer GASLESS-PATRON dispenser smart-treasury PrimordialKosonID ps20 true)
                (let
                    (
                        (ref-TS01-C2:module{TalosStageOne_ClientTwoV2} TS01-C2)
                        (PlebeicStrengthID:string       (ref-AOZ::UR_AutostakePair 1))
                        (ComatiCommandID:string         (ref-AOZ::UR_AutostakePair 2))
                        (PileatiPowerID:string          (ref-AOZ::UR_AutostakePair 3))
                        (TarabostesTenacityID:string    (ref-AOZ::UR_AutostakePair 4))
                        (StrategonVigorID:string        (ref-AOZ::UR_AutostakePair 5))
                        (AsAuthorityID:string           (ref-AOZ::UR_AutostakePair 6))
                        ;;
                        (daily-primordial-left:decimal (ref-DPTF::UR_AccountSupply PrimordialKosonID dispenser))
                        (primordial-split-for-ats:[decimal] (UC_KosonicAutostakeSplit daily-primordial-left op0))
                        ;;
                        (daily-esoteric:decimal (ref-DPTF::UR_AccountSupply EsothericKosonID dispenser))
                        (esoteric-split-for-ats:[decimal] (UC_KosonicAutostakeSplit daily-esoteric op1))
                    )
                ;;Splits the 30% of Primordial Kosons from Dispenser into 6 parts to Fuel Autostake Pools
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PlebeicStrengthID     PrimordialKosonID (at 0 primordial-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser ComatiCommandID       PrimordialKosonID (at 1 primordial-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PileatiPowerID        PrimordialKosonID (at 2 primordial-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser TarabostesTenacityID  PrimordialKosonID (at 3 primordial-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser StrategonVigorID      PrimordialKosonID (at 4 primordial-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser AsAuthorityID         PrimordialKosonID (at 5 primordial-split-for-ats))
                ;;Splits the Esoteric Kosons using the same split, and fuels the Autostake Pools
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PlebeicStrengthID     EsothericKosonID (at 0 esoteric-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser ComatiCommandID       EsothericKosonID (at 1 esoteric-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PileatiPowerID        EsothericKosonID (at 2 esoteric-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser TarabostesTenacityID  EsothericKosonID (at 3 esoteric-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser StrategonVigorID      EsothericKosonID (at 4 esoteric-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser AsAuthorityID         EsothericKosonID (at 5 esoteric-split-for-ats))
                )
            )
        )
    )
    (defun A_KosonMinterStageOne_1of3 ()
        @doc "Executes Stage One Daily Koson Emission, Part 1 of 3"
        (with-capability (DSP|STAGE-ONE-MINTER)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (ref-AOZ:module{AgeOfZalmoxis} AOZ)
                    ;;
                    (PrimordialKosonID:string      (ref-AOZ::UR_PrimalTrueFungible 1))
                    (EsothericKosonID:string       (ref-AOZ::UR_PrimalTrueFungible 2))
                    (op0:integer (ref-DPTF::UR_Decimals PrimordialKosonID))
                    ;;
                    (daily:[decimal] (URC_DailyKOSON false))
                    (ps:[decimal] (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit (at 0 daily) op0))
                    (ps10:decimal (at 0 ps))
                    (ps20:decimal (at 1 ps))
                    (ps40:decimal (at 3 ps))
                    ;;
                    (standard-treasury:string (ref-DALOS::GOV|DHV1|SC_NAME))
                    (smart-treasury:string (ref-DALOS::GOV|DHV2|SC_NAME))
                    (validators:string CST1|SC_NAME)
                    (dispenser:string DSP1|SC_NAME)
                )
                ;;Mints Primordial Koson and Esoteric Koson Amounts
                (ref-TS01-C1::DPTF|C_Mint GASLESS-PATRON dispenser PrimordialKosonID (at 0 daily) false)
                (ref-TS01-C1::DPTF|C_Mint GASLESS-PATRON dispenser EsothericKosonID (at 1 daily) false)
                ;;Moves Primordial Kosons: 10% To Standard-Treasury, 20% to Smart-Treasury, 40% to Custodians(Validators)
                (ref-TS01-C1::DPTF|C_BulkTransfer GASLESS-PATRON dispenser [standard-treasury validators] PrimordialKosonID [ps10 ps40])
                (ref-TS01-C1::DPTF|C_Transfer GASLESS-PATRON dispenser smart-treasury PrimordialKosonID ps20 true)
                
            )
        )
    )
    (defun A_KosonMinterStageOne_2of3 ()
        @doc "Continues Stage One Daily Koson Emission, Part 2 of 3"
        (with-capability (DSP|STAGE-ONE-MINTER)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TS01-C2:module{TalosStageOne_ClientTwoV2} TS01-C2)
                    (ref-AOZ:module{AgeOfZalmoxis} AOZ)
                    ;;
                    (PrimordialKosonID:string       (ref-AOZ::UR_PrimalTrueFungible 1))
                    (PlebeicStrengthID:string       (ref-AOZ::UR_AutostakePair 1))
                    (ComatiCommandID:string         (ref-AOZ::UR_AutostakePair 2))
                    (PileatiPowerID:string          (ref-AOZ::UR_AutostakePair 3))
                    (TarabostesTenacityID:string    (ref-AOZ::UR_AutostakePair 4))
                    (StrategonVigorID:string        (ref-AOZ::UR_AutostakePair 5))
                    (AsAuthorityID:string           (ref-AOZ::UR_AutostakePair 6))
                    ;;
                    (op0:integer (ref-DPTF::UR_Decimals PrimordialKosonID))
                    (dispenser:string DSP1|SC_NAME)
                    ;;
                    (daily-primordial-left:decimal (ref-DPTF::UR_AccountSupply PrimordialKosonID dispenser))
                    (primordial-split-for-ats:[decimal] (UC_KosonicAutostakeSplit daily-primordial-left op0))
                )
                ;;Fuel the 6 ATS Pools, using Primordial Kosons
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PlebeicStrengthID     PrimordialKosonID (at 0 primordial-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser ComatiCommandID       PrimordialKosonID (at 1 primordial-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PileatiPowerID        PrimordialKosonID (at 2 primordial-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser TarabostesTenacityID  PrimordialKosonID (at 3 primordial-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser StrategonVigorID      PrimordialKosonID (at 4 primordial-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser AsAuthorityID         PrimordialKosonID (at 5 primordial-split-for-ats))
            )
        )
    )
    (defun A_KosonMinterStageOne_3of3 ()
        @doc "Finalizes Stage One Daily Koson Emission, Part 3 of 3"
        (with-capability (DSP|STAGE-ONE-MINTER)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TS01-C2:module{TalosStageOne_ClientTwoV2} TS01-C2)
                    (ref-AOZ:module{AgeOfZalmoxis} AOZ)
                    ;;
                    (EsothericKosonID:string        (ref-AOZ::UR_PrimalTrueFungible 2))
                    (PlebeicStrengthID:string       (ref-AOZ::UR_AutostakePair 1))
                    (ComatiCommandID:string         (ref-AOZ::UR_AutostakePair 2))
                    (PileatiPowerID:string          (ref-AOZ::UR_AutostakePair 3))
                    (TarabostesTenacityID:string    (ref-AOZ::UR_AutostakePair 4))
                    (StrategonVigorID:string        (ref-AOZ::UR_AutostakePair 5))
                    (AsAuthorityID:string           (ref-AOZ::UR_AutostakePair 6))
                    ;;
                    (op1:integer (ref-DPTF::UR_Decimals EsothericKosonID))
                    (dispenser:string DSP1|SC_NAME)
                    ;;
                    (daily-esoteric:decimal (ref-DPTF::UR_AccountSupply EsothericKosonID dispenser))
                    (esoteric-split-for-ats:[decimal] (UC_KosonicAutostakeSplit daily-esoteric op1))
                )
                ;;Fuel the 6 ATS Pools, using Esoteric Kosons
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PlebeicStrengthID     EsothericKosonID (at 0 esoteric-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser ComatiCommandID       EsothericKosonID (at 1 esoteric-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PileatiPowerID        EsothericKosonID (at 2 esoteric-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser TarabostesTenacityID  EsothericKosonID (at 3 esoteric-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser StrategonVigorID      EsothericKosonID (at 4 esoteric-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser AsAuthorityID         EsothericKosonID (at 5 esoteric-split-for-ats))
            )
        )
    )

)

