;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 21 of 24
;; This is STEP 21 of 25 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-20 must have run first, including the init steps between deploys.
;; 2 source file(s), 221,896 gas measured in the REPL gas model, 156,723 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact
;;   1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact
;;
;; TOTAL: 2 interface(s), 2 module(s), 4 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact
;;      interface  TalosStageTwo_ClientThreeV1
;;      module     TS02-C3
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact
;;      interface  TalosStageTwo_DemiPadV1
;;      module     TS02-DPAD
;;      table      P|T
;;      table      P|MT
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
(interface TalosStageTwo_ClientThreeV1
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
    (defun AQP-POOL|XB_VacateTrueFungible:string (patron:string executor:string pool-id:string))
    (defun AQP-POOL|XB_VacateOrtoFungible:string (patron:string executor:string pool-id:string dpof-id:string))
    (defun AQP-POOL|XB_VacateSemiFungible:string (patron:string executor:string pool-id:string dpsf-id:string))
    (defun AQP-POOL|XB_VacateNonFungible:string (patron:string executor:string pool-id:string dpnf-id:string))
    ;;{5.7}  User [A/C]
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
    (implements TalosStageTwo_ClientThreeV1)

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
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-POOL|XB_VacateTrueFungible:string
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
    (defun AQP-POOL|XB_VacateOrtoFungible:string
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
    (defun AQP-POOL|XB_VacateSemiFungible:string
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
    (defun AQP-POOL|XB_VacateNonFungible:string
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
    ;;{5.7}  User [A/C]
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
)

;; --- tables for 04_TS02-C3.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact ==============
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_02/0_Interfaces/03_Talos.pact
;;
;; SOVEREIGN launchpad Talos. Holds ONLY the sovereign DEMIPAD orchestration
;; (asset registration/config + deposit/fuel/retrieve/withdraw). The per-sale
;; CITIZEN user wrappers (SPARK|/SNAKES|/CUSTODIANS|/KPAY|/STOAICO|) live in the
;; citizen Talos 2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact, deployed AFTER the
;; citizen sales. Deploy order: DEMIPAD core -> TS02-C1/C2/C3 -> THIS (sovereign)
;; -> citizen sales -> TS02-CPAD (citizen Talos).
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface TalosStageTwo_DemiPadV1
    @doc "Exposes Ouronet Stage Two Demipad SOVEREIGN Client Functions"

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
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A]
    ;;
    (defun A_RegisterAssetToLaunchpad (patron:string executor:string asset-id:string fungibility:[bool]))
    (defun A_ToggleOpenForBusiness (executor:string asset-id:string toggle:bool))
    (defun A_DefinePrice (executor:string asset-id:string price:object))
    (defun A_ToggleRetrieval (executor:string asset-id:string toggle:bool))
    ;;
    ;;  [C]
    ;;
    (defun DEMIPAD|C_Deposit (patron:string executor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal))
    ;;
    (defun DEMIPAD|C_Withdraw (patron:string executor:string asset-id:string type:integer destination:string))
    ;;
    (defun DEMIPAD|C_FuelTrueFungible (patron:string executor:string asset-id:string amount:decimal))
    (defun DEMIPAD|C_FuelOrtoFungible (patron:string executor:string asset-id:string nonces:[integer]))
    (defun DEMIPAD|C_FuelSemiFungible (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer]))
    (defun DEMIPAD|C_FuelNonFungible (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer]))
    (defun DEMIPAD|C_RetrieveTrueFungible (patron:string executor:string asset-id:string amount:decimal))
    (defun DEMIPAD|C_RetrieveOrtoFungible (patron:string executor:string asset-id:string nonces:[integer]))
    (defun DEMIPAD|C_RetrieveSemiFungible (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer]))
    (defun DEMIPAD|C_RetrieveNonFungible (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer]))

)
;;
(module TS02-DPAD GOV
    @doc "TALOS Stage 2 Demiourgos Launchpad SOVEREIGN Functions"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageTwo_DemiPadV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS02-DPAD                          (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS02-DPAD_ADMIN)))
    (defcap GOV|TS02-DPAD_ADMIN ()                      (enforce-guard GOV|MD_TS02-DPAD))
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
            (enforce (not gap) "While Global Administrative Pause is online, no executor Functions can be executed")
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
        (with-capability (GOV|TS02-DPAD_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|TS02-DPAD_ADMIN)
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
        (with-capability (GOV|TS02-DPAD_ADMIN)
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
        (with-capability (GOV|TS02-DPAD_ADMIN)
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
        @doc "Registers THIS sovereign launchpad Talos' summoner guard as a trusted IMP peer of the \
            \ sovereign modules it drives (DEMIPAD core + DPDC for direct XB_DeployAccount). The \
            \ per-sale CITIZEN modules are registered by the citizen Talos (TS02-CPAD)."
        (let
            (
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (ref-P|DPAD:module{OuronetPolicyV2} DEMIPAD)
                (ref-P|DPDC:module{OuronetPolicyV2} DPDC)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|TS01-A::P|A_AddIMP mg)
            (ref-P|DPAD::P|A_AddIMP mg)
            ;;DPDC Audit #35M: TS02-DPAD calls DPDC::XBv_DeployAccountSFT/NFT directly (the removed
            ;;DPSF|C_DeployAccount/DPNF|C_DeployAccount Talos wrappers previously carried TS02-C1/C2's
            ;;own registered guard through the call chain instead) -- register this module's own guard
            ;;as a trusted DPDC peer so P|UEV_IMC recognizes the direct call.
            (ref-P|DPDC::P|A_AddIMP mg)
            ;;IGNIS RESTRUCTURE 2026-09-20: the collectors became protected X_ functions
            ;;behind `P|UEV_IMC`, so every module that bills must be a registered IMP peer
            ;;of IGNIS or the fee call dies with "None of the guards passed".
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
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
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
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
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_RegisterAssetToLaunchpad (patron:string executor:string asset-id:string fungibility:[bool])
        @doc "Registers an Asset to Launchpad; \
            \ An Asset can be a DPTF, DPMF, DPSF or DPNF \
            \   Asset-type can be designated via the double-boolean <fungibility> \
            \   \
            \   DPFT >> [true true] \
            \   DPMF >> [true false] \
            \   DPSF >> [false true] \
            \   DPNF >> [false false]"
        (with-capability (P|TALOS-SUMMONER)
            (let
                (
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-DPDC:module{DpdcV2} DPDC)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                    (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                    (tf:[bool] [true true])
                    (of:[bool] [true false])
                    (sf:[bool] [false true])
                    (nf:[bool] [false false])
                    (f:bool false)
                )
                (ref-DEMIPAD::A_RegisterAssetToLaunchpad patron executor asset-id fungibility)
                ;;Reconciles two audits' DeployAccount hardening (dptf-dpof #N2 + DPDC #35M):
                ;; #N2: lpad is DEMIPAD's own system smart account (not patron's) — tf/of use the ADMIN
                ;;   variant (TS01-A, no ownership check on <account>); the self-service C_ variant now
                ;;   requires the caller to own <account>, which they don't for lpad.
                ;; #35M: the public DPSF|C_DeployAccount/DPNF|C_DeployAccount Talos wrappers were REMOVED
                ;;   (any signer could force any account onto any collection); sf/nf now call
                ;;   DPDC::XBv_DeployAccountSFT/NFT directly, module-to-module — the pattern every
                ;;   legitimate internal caller (DPDC-C/DPDC-F/DPDC-R/DPDC-S) already uses.
                ;;PROVISIONAL EXECUTOR SLOTS (HANDOFF 4e, 2026-09-22). 01_TS01-A's turn gave the
                ;;two admin DeployAccount wrappers an <executor>, proven by
                ;;CAP_EnforceAccountOwnership, and an <executee> -- the account deployed FOR,
                ;;which is <lpad> here. This module's own turn has not come, so there is no
                ;;<executor> parameter to thread and the rule is to pass the account that
                ;;actually initiates. That is <patron>: the @doc above records that running this
                ;;requires TS01-A's admin keyset, so the caller IS the admin and the admin is
                ;;paying. Correct today, and it must become this module's own <executor> at its
                ;;turn -- `executor = patron` is a considered choice here, never a default.
                (cond
                    ((= fungibility tf) (ref-TS01-A::DPTF|A_DeployAccount patron patron lpad asset-id))
                    ((= fungibility of) (ref-TS01-A::DPOF|A_DeployAccount patron patron lpad asset-id))
                    ((= fungibility sf) (ref-DPDC::XBv_DeployAccountSFT lpad asset-id f f f f f f f f f f f))
                    ((= fungibility nf) (ref-DPDC::XBv_DeployAccountNFT lpad asset-id f f f f f f f f f f))
                    true
                )
            )
        )
    )
    (defun A_ToggleOpenForBusiness (executor:string asset-id:string toggle:bool)
        @doc "Toggle Open For Bussines. Must be on to acquire Assets"
        (with-capability (P|TALOS-SUMMONER)
            (let
                (
                    (ref-DALOS-G:module{OuronetDalosV2} DALOS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                )
                ;;GASLESS admin path: this Talos A_ wrapper takes no patron, so the core's patron
                ;;slot carries the Ouronet system account, read from the same source
                ;;TS01-A's GASLESS-PATRON constant resolves to. The EXECUTOR is threaded: the
                ;;admin keyset says the call MAY happen, the executor says who made it happen.
                (ref-DEMIPAD::A_ToggleOpenForBusiness (ref-DALOS-G::GOV|DALOS|SC_NAME) executor asset-id toggle)
            )
        )
    )
    (defun A_DefinePrice (executor:string asset-id:string price:object)
        @doc "Updates Price Object for an Asset"
        (with-capability (P|TALOS-SUMMONER)
            (let
                (
                    (ref-DALOS-G:module{OuronetDalosV2} DALOS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                )
                ;;GASLESS admin path: this Talos A_ wrapper takes no patron, so the core's patron
                ;;slot carries the Ouronet system account, read from the same source
                ;;TS01-A's GASLESS-PATRON constant resolves to. The EXECUTOR is threaded: the
                ;;admin keyset says the call MAY happen, the executor says who made it happen.
                (ref-DEMIPAD::A_DefinePrice (ref-DALOS-G::GOV|DALOS|SC_NAME) executor asset-id price)
            )
        )
    )
    (defun A_ToggleRetrieval (executor:string asset-id:string toggle:bool)
        @doc "Retrieval ON allows Asset Owners to retrieve their Asssets that still exist on the Launchpad"
        (with-capability (P|TALOS-SUMMONER)
            (let
                (
                    (ref-DALOS-G:module{OuronetDalosV2} DALOS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                )
                ;;GASLESS admin path: this Talos A_ wrapper takes no patron, so the core's patron
                ;;slot carries the Ouronet system account, read from the same source
                ;;TS01-A's GASLESS-PATRON constant resolves to. The EXECUTOR is threaded: the
                ;;admin keyset says the call MAY happen, the executor says who made it happen.
                (ref-DEMIPAD::A_ToggleRetrieval (ref-DALOS-G::GOV|DALOS|SC_NAME) executor asset-id toggle)
            )
        )
    )
    (defun DEMIPAD|C_Deposit (patron:string executor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal)
        @doc "Sovereign launchpad DEPOSIT Talos op — the citizen sales call this to move a buyer's \
            \ STOA/OURS working-token into the Launchpad against <asset-id>. <type> 0 = Native STOA \
            \ (wrapped), 1 = OWS; <max-cost> is the buyer's dollar slippage ceiling (sentinel < 0 = \
            \ slippage off). IGNIS billed on patron here; the sale composes it Sigma-wise with its \
            \ asset-transfer Talos op."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                    (sd:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DEMIPAD::C_Deposit patron executor asset-id amount-in-dollars type direct-injection max-cost)
                )
                (format "Succesfuly deposited {} $ worth against {} into Demipad from {}." [amount-in-dollars asset-id sd])
            )
        )
    )
    ;;
    (defun DEMIPAD|C_Withdraw (patron:string executor:string asset-id:string type:integer destination:string)
        @doc "Withdraws all cumulated Tokens in the Launchpad, gathered through sale \
            \ Type 1 = WSTOA \
            \ Type 2 = SSTOA \
            \ Type 3 = OURO "
        (with-capability (P|TS)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                    (retrieval-amount:decimal (ref-DEMIPAD::URv_Funds asset-id type))
                    (working-id:string
                        (if (= type 1)
                            (ref-DALOS::UR_WrappedStoaID)
                            (if (= type 2)
                                (ref-DALOS::UR_SilverStoaID)
                                (ref-DALOS::UR_OuroborosID)
                            )
                        )
                    )
                    (sd:string (ref-I|OURONET::OI|UC_ShortAccount destination))
                )
                (ref-DEMIPAD::C_Withdraw patron executor asset-id type destination)
                (format "Succesfuly withdrawn {} {} from Demipad to {}." [retrieval-amount working-id sd])
            )
        )
    )
    ;;
    (defun DEMIPAD|C_FuelTrueFungible (patron:string executor:string asset-id:string amount:decimal)
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                )
                (ref-DEMIPAD::C_TransmitTrueFungible patron executor asset-id amount true)
            )
        )
    )
    (defun DEMIPAD|C_FuelOrtoFungible (patron:string executor:string asset-id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                )
                (ref-DEMIPAD::C_TransmitOrtoFungible patron executor asset-id nonces true)
            )
        )
    )
    (defun DEMIPAD|C_FuelSemiFungible (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DEMIPAD::C_TransmitSemiFungibles patron executor asset-id nonces amounts true)
                )
                (format "Succesfuly fueled {} Nonces {} with Amounts {} to Demiourgos Launchpad from Account {}" [asset-id nonces amounts c])
            )
        )
    )
    (defun DEMIPAD|C_FuelNonFungible (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DEMIPAD::C_TransmitNonFungibles patron executor asset-id nonces amounts true)
                )
                (format "Succesfuly fueled {} Nonces {} with Amounts {} to Demiourgos Launchpad from Account {}" [asset-id nonces amounts c])
            )
        )
    )
    ;;
    (defun DEMIPAD|C_RetrieveTrueFungible (patron:string executor:string asset-id:string amount:decimal)
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                )
                (ref-DEMIPAD::C_TransmitTrueFungible patron executor asset-id amount false)
            )
        )
    )
    (defun DEMIPAD|C_RetrieveOrtoFungible (patron:string executor:string asset-id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                )
                (ref-DEMIPAD::C_TransmitOrtoFungible patron executor asset-id nonces false)
            )
        )
    )
    (defun DEMIPAD|C_RetrieveSemiFungible (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DEMIPAD::C_TransmitSemiFungibles patron executor asset-id nonces amounts false)
                )
                (format "Succesfuly retrieved {} Nonces {} with Amounts {} from Demiourgos Launchpad to Account {}" [asset-id nonces amounts c])
            )
        )
    )
    (defun DEMIPAD|C_RetrieveNonFungible (patron:string executor:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DEMIPAD::C_TransmitNonFungibles patron executor asset-id nonces amounts false)
                )
                (format "Succesfuly retrieved {} Nonces {} with Amounts {} from Demiourgos Launchpad to Account {}" [asset-id nonces amounts c])
            )
        )
    )

)

;; --- tables for 05_TS02-DPAD.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

