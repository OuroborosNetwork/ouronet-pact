;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 20 of 22
;; This is STEP 20 of 23 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-19 must have run first, including the init steps between deploys.
;; 7 module(s), 221,896 gas measured in the REPL gas model, 318,440 bytes
;;
;; Modules in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_02/3_Talos/04_TS02-C3.pact
;;   1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact
;;   2_CITIZEN/7_Launchpad/1_Spark/01_Spark.pact
;;   2_CITIZEN/7_Launchpad/2_Snakes/02_Snakes.pact
;;   2_CITIZEN/7_Launchpad/3_Custodians/03_Custodians.pact
;;   2_CITIZEN/7_Launchpad/4_StoicPay/04_STOICPAY.pact
;;   2_CITIZEN/7_Launchpad/5_StoicIco/05_STOAICO.pact
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
    (defun AQP-POOL|XB_VacateTrueFungible:string (patron:string pool-id:string))
    (defun AQP-POOL|XB_VacateOrtoFungible:string (patron:string pool-id:string dpof-id:string))
    (defun AQP-POOL|XB_VacateSemiFungible:string (patron:string pool-id:string dpsf-id:string))
    (defun AQP-POOL|XB_VacateNonFungible:string (patron:string pool-id:string dpnf-id:string))
    ;;{5.7}  User [A/C]
    ;;
    ;;  [ANK]
    ;;
    (defun AQP-ANK|C_RevokeBoostClass:string (patron:string boost-class-id:string))
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
    (defun AQP-ANK|C_RevokeAnchor:string (patron:string anchor-id:string))
    ;;
    ;;  [AQP-SCORE]
    ;;
    (defun AQP-SCR|C_IssueLiquidityScore:string
        (patron:string owner-konto:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
    )
    (defun AQP-SCR|C_IssueTrueFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer mx-frozen:decimal)
    )
    (defun AQP-SCR|C_IssueOrtoFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
    )
    (defun AQP-SCR|C_IssueSemiFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer sft-equality:bool)
    )
    (defun AQP-SCR|C_IssueNonFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer nft-score-model:integer)
    )
    (defun AQP-SCR|C_RotateScoreOwnership:string (patron:string score-id:string new-owner-konto:string))
    (defun AQP-SCR|C_ControlScore:string (patron:string score-id:string new-can-upgrade:bool new-can-change-owner:bool))
    (defun AQP-SCR|C_CreateScoreBoostClassLink:string (patron:string score-id:string boost-class-id:string))
    (defun AQP-SCR|C_CreateScoreBoostLink:string (patron:string score-id:string boost-score-id:string))
    (defun AQP-SCR|C_EnableDebBoost:string (patron:string score-id:string))
    (defun AQP-SCR|C_IssueTriplet:string
        (patron:string executor:string bronze-score-id:string silver-score-id:string golden-score-id:string)
    )
    (defun AQP-SCR|C_IssueSingleScoreModel:string
        (patron:string executor:string model-name:string score-class:integer collectable-id:string precision:integer nonces:[integer] nonce-score-values:[decimal] boost-class-id:string)
    )
    (defun AQP-SCR|C_CombineTripletScoreModel:string
        (patron:string executor:string model-name:string bronze-model-id:string silver-model-id:string golden-model-id:string)
    )
    (defun AQP-SCR|C_IssueScoreFromModel:string (patron:string owner-konto:string model-id:string agency-name:string))
    (defun AQP-SCR|C_IssueSemiFungibleScoreDefinition:string
        (patron:string score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
    )
    (defun AQP-SCR|C_IssueNonFungibleScoreDefinition:string
        (patron:string score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
    )
    (defun AQP-SCR|C_IssueNonFungibleSetScoreDefinition:string
        (patron:string score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
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
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
        )
    )
    (defun AQP-POOL|CC_UnstakeSemiFungibleCollectable:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
            nonce-amounts:[integer]
        )
    )
    (defun AQP-POOL|CC_StakeNonFungibleCollectable:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
        )
    )
    (defun AQP-POOL|CC_UnstakeNonFungibleCollectable:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
            nonce-amounts:[integer]
        )
    )
    ;;
    (defun AQP-POOL|CC_StakeTrueFungible:string
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
    )
    (defun AQP-POOL|CC_UnstakeTrueFungible:string
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
    )
    (defun AQP-POOL|CC_StakeOrtoFungible:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
        )
    )
    (defun AQP-POOL|CC_UnstakeOrtoFungible:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
        )
    )
    (defun AQP-POOL|C_SyncTrueFungibleAnchors:string
        (patron:string beneficiary-id:string dptf-id:string)
    )
    (defun AQP-POOL|C_SyncSemiFungibleAnchors:string
        (patron:string beneficiary-id:string dpsf-id:string)
    )
    (defun AQP-POOL|C_SyncNonFungibleAnchors:string
        (patron:string beneficiary-id:string dpnf-id:string)
    )
    (defun AQP-POOL|C_AbortVacate:string
        (patron:string pool-id:string)
    )
    (defun AQP-POOL|C_FinalizeVacate:string (patron:string pool-id:string))
    (defun AQP-POOL|CC_FullVacate:string (patron:string pool-id:string))
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
        (patron:string fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
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
        (patron:string executor:string fvt-id:string new-owner-konto:string)
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
        (patron:string owner-konto:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
    )
    (defun AQP-FVT|CC_InjectStream:string
        (patron:string injector:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
    )
    (defun AQP-FVT|CC_Inject:string
        (patron:string injector:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun AQP-FVT|CCp_InjectFixChunk:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
    )
    (defun AQP-FVT|CC_InjectFinalize:string
        (patron:string injector:string fvt-id:string reward-dptf-id:string amount:decimal)
    )
    (defun AQP-FVT|CCp_UnstaleAll:string
        (patron:string fvt-id:string reward-dptf-id:string chunk:integer)
    )
    (defun MTX-AQP|2|CC_Inject:string
        (patron:string injector:string fvt-id:string reward-dptf-id:string amount:decimal)
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
        (patron:string fvt-ids:[string])
    )
    (defun AQP-FVT|CC_Collect:string
        (patron:string collector:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
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
    (defun AQP-DSA|A_ToggleExternalOracle:string (on:bool))
    (defun AQP-DSA|A_SetOracleValidity:string (seconds:integer))

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
        (patron:string pool-id:string)
        @doc "Vacate rehaul — pool-owner vacate of a pool's TrueFungible leg only (one tx; used standalone or by \
            \ the agnostic CC_FullVacate for a class-1 TF+OF pool). Owner enforced in VCT|C>VACATE; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::XB_VacateTrueFungible pool-id))
                (format "Successfully vacated the TrueFungible leg of Pool {}." [pool-id])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-POOL|XB_VacateOrtoFungible:string
        (patron:string pool-id:string dpof-id:string)
        @doc "Vacate rehaul — pool-owner vacate of ONE OrtoFungible asset of a pool (one tx; standalone or per \
            \ class-1 satellite). Owner enforced in VCT|C>VACATE; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::XB_VacateOrtoFungible pool-id dpof-id))
                (format "Successfully vacated OrtoFungible {} of Pool {}." [dpof-id pool-id])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-POOL|XB_VacateSemiFungible:string
        (patron:string pool-id:string dpsf-id:string)
        @doc "Vacate rehaul — pool-owner vacate of the DPSF (semi-fungible) collection of a class-3 pool (one tx). \
            \ Owner enforced in VCT|C>VACATE; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::XB_VacateSemiFungible pool-id dpsf-id))
                (format "Successfully vacated SemiFungible {} of Pool {}." [dpsf-id pool-id])
            )
        )
    )
    ;;Protection: Class 3 — Custom: P|TS
    (defun AQP-POOL|XB_VacateNonFungible:string
        (patron:string pool-id:string dpnf-id:string)
        @doc "Vacate rehaul — pool-owner vacate of the DPNF (non-fungible) collection of a class-4 pool (one tx). \
            \ Owner enforced in VCT|C>VACATE; IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::XB_VacateNonFungible pool-id dpnf-id))
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
    (defun AQP-DSA|A_ToggleExternalOracle:string (on:bool)
        @doc "DSA (Talos): MODULE ADMIN (GOV) flip of the SINGULAR GLOBAL external-oracle switch for ALL agencies. \
            \ No IGNIS billing (pure governance, master-signed, no OutputCumulator)."
        (with-capability (P|TS)
            (let
                (
                    (ref-DSA:module{DsaV1} AQP-DSA)
                )
                (ref-DSA::A_ToggleExternalOracle on)
                (format "Global external-oracle switch set to {}." [on])
            )
        )
    )
    (defun AQP-DSA|A_SetOracleValidity:string (seconds:integer)
        @doc "DSA (Talos): MODULE ADMIN (GOV) set of the GLOBAL oracle-validity window (freshness horizon, seconds). \
            \ No IGNIS billing (pure governance, master-signed, no OutputCumulator)."
        (with-capability (P|TS)
            (let
                (
                    (ref-DSA:module{DsaV1} AQP-DSA)
                )
                (ref-DSA::A_SetOracleValidity seconds)
                (format "Global oracle-validity window set to {} seconds." [seconds])
            )
        )
    )
    ;;
    (defun AQP-ANK|C_RevokeBoostClass:string
        (patron:string boost-class-id:string)
        @doc "Revokes an empty BoostClass."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ANK::C_RevokeBoostClass boost-class-id)
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
    (defun AQP-ANK|C_RevokeAnchor:string (patron:string anchor-id:string)
        @doc "Revokes an existing Anchor, removing it from its BoostClass and AssetAnchors bookkeeping."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                )
                (ref-IGNIS::XE_CollectIgnis patron 
                    (ref-ANK::C_RevokeAnchor anchor-id)
                )
                (format "Successfully revoked Anchor {}." [anchor-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueLiquidityScore:string
        (patron:string owner-konto:string score-name:string precision:integer lp-denominator:string mx-frozen:decimal mx-sleeping:decimal)
        @doc "Issues score-class 0 (LP) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueLiquidityScore patron owner-konto score-name precision lp-denominator mx-frozen mx-sleeping)
                )
                (format "Successfully issued Liquidity Score {} for owner {}." [score-name owner-konto])
            )
        )
    )
    (defun AQP-SCR|C_IssueTrueFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer mx-frozen:decimal)
        @doc "Issues score-class 1 (DPTF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueTrueFungibleScore patron owner-konto score-name precision mx-frozen)
                )
                (format "Successfully issued TrueFungible Score {} for owner {}." [score-name owner-konto])
            )
        )
    )
    (defun AQP-SCR|C_IssueOrtoFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer mx-sleeping:decimal mx-hibernated:decimal)
        @doc "Issues score-class 2 (DPOF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueOrtoFungibleScore patron owner-konto score-name precision mx-sleeping mx-hibernated)
                )
                (format "Successfully issued OrtoFungible Score {} for owner {}." [score-name owner-konto])
            )
        )
    )
    (defun AQP-SCR|C_IssueSemiFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer sft-equality:bool)
        @doc "Issues score-class 3 (DPSF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueSemiFungibleScore patron owner-konto score-name precision sft-equality)
                )
                (format "Successfully issued SemiFungible Score {} for owner {}." [score-name owner-konto])
            )
        )
    )
    (defun AQP-SCR|C_IssueNonFungibleScore:string
        (patron:string owner-konto:string score-name:string precision:integer nft-score-model:integer)
        @doc "Issues score-class 4 (DPNF) in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueNonFungibleScore patron owner-konto score-name precision nft-score-model)
                )
                (format "Successfully issued NonFungible Score {} for owner {}." [score-name owner-konto])
            )
        )
    )
    (defun AQP-SCR|C_RotateScoreOwnership:string (patron:string score-id:string new-owner-konto:string)
        @doc "Rotates score ownership in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_RotateOwnership score-id new-owner-konto))
                (format "Successfully rotated ownership for score {} to {}." [score-id new-owner-konto])
            )
        )
    )
    (defun AQP-SCR|C_ControlScore:string (patron:string score-id:string new-can-upgrade:bool new-can-change-owner:bool)
        @doc "Updates score control flags in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_Control score-id new-can-upgrade new-can-change-owner)
                )
                (format "Successfully updated control flags for score {}." [score-id])
            )
        )
    )
    (defun AQP-SCR|C_CreateScoreBoostClassLink:string (patron:string score-id:string boost-class-id:string)
        @doc "Creates score -> boost-class link in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_CreateBoostClassLink score-id boost-class-id))
                (format "Successfully linked score {} to BoostClass {}." [score-id boost-class-id])
            )
        )
    )
    (defun AQP-SCR|C_CreateScoreBoostLink:string (patron:string score-id:string boost-score-id:string)
        @doc "Creates score -> boost-score link in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_CreateBoostLink score-id boost-score-id))
                (format "Successfully linked score {} to boost score {}." [score-id boost-score-id])
            )
        )
    )
    (defun AQP-SCR|C_EnableDebBoost:string (patron:string score-id:string)
        @doc "Enables irreversible DEB boost on the score row. Medium IGNIS cost; no native STOA."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-SCR::C_EnableDebBoost score-id))
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
    (defun AQP-SCR|C_IssueScoreFromModel:string (patron:string owner-konto:string model-id:string agency-name:string)
        @doc "FACTORY (Talos): issue a conforming score entity from <model-id> for owner-konto; collects IGNIS on \
            \ patron. Returns the (score | triplet) id."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-SCR::C_IssueScoreFromModel patron owner-konto model-id agency-name)
                    )
                    (entity-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Successfully issued score entity {} from model {}." [entity-id model-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueSemiFungibleScoreDefinition:string
        (patron:string score-id:string dpsf-id:string nonces:[integer] nonce-score-values:[decimal])
        @doc "Writes DPSF nonce score definitions in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueSemiFungibleScoreDefinition score-id dpsf-id nonces nonce-score-values)
                )
                (format "Successfully issued SemiFungible score definitions for score {} and dpsf-id {}." [score-id dpsf-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueNonFungibleScoreDefinition:string
        (patron:string score-id:string dpnf-id:string trait-keys:[string] trait-values:[string] trait-score-values:[decimal])
        @doc "Writes DPNF trait score definitions in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueNonFungibleScoreDefinition score-id dpnf-id trait-keys trait-values trait-score-values)
                )
                (format "Successfully issued NonFungible score definitions for score {} and dpnf-id {}." [score-id dpnf-id])
            )
        )
    )
    (defun AQP-SCR|C_IssueNonFungibleSetScoreDefinition:string
        (patron:string score-id:string dpnf-id:string dpnf-nonce-classes:[integer] class-score-values:[decimal])
        @doc "Writes DPNF set-mode (nonce-class) score definitions in AQP-SCORE and collects resulting IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-SCR:module{AcquisitionScoresV1} AQP-SCORE)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-SCR::C_IssueNonFungibleSetScoreDefinition score-id dpnf-id dpnf-nonce-classes class-score-values)
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
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Stake DPTF (or native|F| LP) into pool-id. Talos client shell: event cap + FVT::CC_TrueFungibleStakeFlow direction=true."
        (with-capability (AQP|C>STAKE-TRUE-FUNGIBLE patron pool-id owner-id beneficiary-id dptf-id amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_TrueFungibleStakeFlow pool-id owner-id beneficiary-id dptf-id amount true)
                )
                (UC_FormatStakeTrueFungibleResult pool-id owner-id beneficiary-id dptf-id amount)
            )
        )
    )
    (defun AQP-POOL|CC_UnstakeTrueFungible:string
        (patron:string pool-id:string owner-id:string beneficiary-id:string dptf-id:string amount:decimal)
        @doc "Unstake DPTF from pool-id. Talos client shell: event cap + FVT::CC_TrueFungibleStakeFlow direction=false."
        (with-capability (AQP|C>UNSTAKE-TRUE-FUNGIBLE patron pool-id owner-id beneficiary-id dptf-id amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::CC_TrueFungibleStakeFlow pool-id owner-id beneficiary-id dptf-id amount false)
                )
                (UC_FormatUnstakeTrueFungibleResult pool-id owner-id beneficiary-id dptf-id amount)
            )
        )
    )
    (defun AQP-POOL|CC_StakeOrtoFungible:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
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
            (with-capability (AQP|C>STAKE-ORTO-FUNGIBLE patron pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_OrtoFungibleStakeFlow
                            pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts true
                        )
                    )
                    (UC_FormatStakeOrtoFungibleResult pool-id owner-id beneficiary-id dpof-id nonce-count)
                )
            )
        )
    )
    (defun AQP-POOL|CC_UnstakeOrtoFungible:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            dpof-id:string
            nonces:[integer]
        )
        @doc "Unstake whole DPOF nonces via C_Transfer from the (owner, beneficiary) row. M5: beneficiary-id is \
            \ caller-supplied (self OR foreign) so the exact staked row is located — mirrors TF. Poll UR_NoncesSupplies, \
            \ then @event cap with resolved legs."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[decimal] (ref-DPOF::UR_NoncesSupplies dpof-id nonces))
            )
            (with-capability (AQP|C>UNSTAKE-ORTO-FUNGIBLE patron pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_OrtoFungibleStakeFlow
                            pool-id owner-id beneficiary-id dpof-id nonces nonce-amounts false
                        )
                    )
                    (UC_FormatUnstakeOrtoFungibleResult pool-id owner-id dpof-id nonce-count)
                )
            )
        )
    )
    ;;
    (defun AQP-POOL|CC_StakeSemiFungibleCollectable:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
        )
        @doc "Stake DPSF collectable (son=true). Poll DPDC::UR_AccountNoncesSupplies, then FVT::CC_CollectableStakeFlow."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[integer] (ref-DPDC::UR_AccountNoncesSupplies owner-id collectable-id true nonces))
            )
            (with-capability
                (AQP|C>STAKE-SEMI-FUNGIBLE-COLLECTABLE
                    patron pool-id owner-id beneficiary-id collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_CollectableStakeFlow
                            pool-id owner-id beneficiary-id collectable-id true nonces nonce-amounts true
                        )
                    )
                    (UC_FormatStakeCollectableResult
                        pool-id owner-id beneficiary-id collectable-id true nonce-count
                    )
                )
            )
        )
    )
    (defun AQP-POOL|CC_UnstakeSemiFungibleCollectable:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
            nonce-amounts:[integer]
        )
        @doc "Unstake DPSF collectable (son=true) from the (owner, beneficiary) row. M5: beneficiary-id caller-supplied \
            \ (self OR foreign) so the exact staked row is located — mirrors TF."
        (let
            (
                (nonce-count:integer (length nonces))
            )
            (with-capability
                (AQP|C>UNSTAKE-SEMI-FUNGIBLE-COLLECTABLE
                    patron pool-id owner-id beneficiary-id collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_CollectableStakeFlow
                            pool-id owner-id beneficiary-id collectable-id true nonces nonce-amounts false
                        )
                    )
                    (UC_FormatUnstakeCollectableResult pool-id owner-id collectable-id true nonce-count)
                )
            )
        )
    )
    (defun AQP-POOL|CC_StakeNonFungibleCollectable:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
        )
        @doc "Stake DPNF collectable (son=false). Poll DPDC::UR_AccountNoncesSupplies, then FVT::CC_CollectableStakeFlow."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (nonce-count:integer (length nonces))
                (nonce-amounts:[integer] (ref-DPDC::UR_AccountNoncesSupplies owner-id collectable-id false nonces))
            )
            (with-capability
                (AQP|C>STAKE-NON-FUNGIBLE-COLLECTABLE
                    patron pool-id owner-id beneficiary-id collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_CollectableStakeFlow
                            pool-id owner-id beneficiary-id collectable-id false nonces nonce-amounts true
                        )
                    )
                    (UC_FormatStakeCollectableResult
                        pool-id owner-id beneficiary-id collectable-id false nonce-count
                    )
                )
            )
        )
    )
    (defun AQP-POOL|CC_UnstakeNonFungibleCollectable:string
        (
            patron:string
            pool-id:string
            owner-id:string
            beneficiary-id:string
            collectable-id:string
            nonces:[integer]
            nonce-amounts:[integer]
        )
        @doc "Unstake DPNF collectable (son=false) from the (owner, beneficiary) row. M5: beneficiary-id caller-supplied \
            \ (self OR foreign) so the exact staked row is located — mirrors TF."
        (let
            (
                (nonce-count:integer (length nonces))
            )
            (with-capability
                (AQP|C>UNSTAKE-NON-FUNGIBLE-COLLECTABLE
                    patron pool-id owner-id beneficiary-id collectable-id nonces nonce-amounts
                )
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    )
                    (ref-IGNIS::XE_CollectIgnis patron
                        (ref-FVT::CC_CollectableStakeFlow
                            pool-id owner-id beneficiary-id collectable-id false nonces nonce-amounts false
                        )
                    )
                    (UC_FormatUnstakeCollectableResult pool-id owner-id collectable-id false nonce-count)
                )
            )
        )
    )
    ;;
    ;; Vacate — Full (1 tx) or Stateless Legs (N txs; auto-begin; finalize on last)
    ;;
    (defun AQP-POOL|C_AbortVacate:string
        (patron:string pool-id:string)
        @doc "Clear vacate-in-progress; stake stays disabled. Talos → AQP-VCT::C_AbortVacate."
        (with-capability (AQP|C>ABORT-VACATE patron pool-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VCT::C_AbortVacate pool-id)
                )
                (format "Successfully aborted vacate-in-progress on Pool {} (stake remains disabled)."
                    [pool-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_FinalizeVacate:string
        (patron:string pool-id:string)
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
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::C_FinalizeVacate pool-id))
                (format "Successfully finalized vacate on Pool {} — scores nuked, stake re-enabled." [pool-id])
            )
        )
    )
    (defun AQP-POOL|CC_FullVacate:string
        (patron:string pool-id:string)
        @doc "Vacate rehaul — pool-owner AGNOSTIC full vacate (one tx): input is JUST the pool-id. VCT reads the \
            \ pool class + scans its inventory on-chain and vacates every asset type. Owner enforced in VCT|C>VACATE; \
            \ collects IGNIS on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-VCT:module{AcquisitionVacateV1} AQP-VCT)
                )
                (ref-IGNIS::XE_CollectIgnis patron (ref-VCT::CC_FullVacate pool-id))
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
                    (ref-VCT::CCp_BatchDrainOrtoFungible pool-id dpof-id owner-ids beneficiary-ids nonces-array))
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
                    (ref-VCT::CCp_BatchVacateOrtoFungible pool-id dpof-id owner-ids beneficiary-ids nonces-array))
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
        (patron:string beneficiary-id:string dptf-id:string)
        @doc "Pool-agnostic TF anchor repair for beneficiary × dptf-id. Talos shell → AQP-POOL::C_SyncTrueFungibleAnchors."
        (with-capability (AQP|C>SYNC-TF-ANCHORS patron beneficiary-id dptf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_SyncTrueFungibleAnchors patron beneficiary-id dptf-id)
                )
                (format "Successfully synced TrueFungible anchors for beneficiary {} on {}."
                    [(UC_ShortAccount beneficiary-id) dptf-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_SyncSemiFungibleAnchors:string
        (patron:string beneficiary-id:string dpsf-id:string)
        @doc "Pool-agnostic DPSF anchor repair. Talos shell → AQP-POOL::C_SyncCollectableAnchors son=true."
        (with-capability (AQP|C>SYNC-SEMI-FUNGIBLE-ANCHORS patron beneficiary-id dpsf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_SyncCollectableAnchors patron beneficiary-id dpsf-id true)
                )
                (format "Successfully synced SemiFungible anchors for beneficiary {} on {}."
                    [(UC_ShortAccount beneficiary-id) dpsf-id]
                )
            )
        )
    )
    (defun AQP-POOL|C_SyncNonFungibleAnchors:string
        (patron:string beneficiary-id:string dpnf-id:string)
        @doc "Pool-agnostic DPNF anchor repair. Talos shell → AQP-POOL::C_SyncCollectableAnchors son=false."
        (with-capability (AQP|C>SYNC-NON-FUNGIBLE-ANCHORS patron beneficiary-id dpnf-id)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-AQP::C_SyncCollectableAnchors patron beneficiary-id dpnf-id false)
                )
                (format "Successfully synced NonFungible anchors for beneficiary {} on {}."
                    [(UC_ShortAccount beneficiary-id) dpnf-id]
                )
            )
        )
    )
    ;;
    ;; --- AQP-FVT lifecycle (Talos client shell → AQP-FVT::C_*) ---
    (defun AQP-FVT|C_Issue:string
        (patron:string fvt-name:string owner-konto:string fvt-class:integer common-denominator:string)
        @doc "Issues an FVT (farm/vault/treasury) and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                    (ico:object{IgnisCollectorV3.OutputCumulator}
                        (ref-FVT::C_Issue patron fvt-name owner-konto fvt-class common-denominator)
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
        (patron:string executor:string fvt-id:string new-owner-konto:string)
        @doc "Rotates FVT ownership and collects IGNIS output on patron."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-FVT:module{AcquisitionFarmsVaultsTreasuriesV1} AQP-FVT)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-FVT::C_RotateOwnership patron executor fvt-id new-owner-konto)
                )
                (format "Successfully rotated ownership for FVT {} to {}." [fvt-id new-owner-konto])
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
        (patron:string owner-konto:string vault-name:string stake-dptf-id:string reward-dptf-id:string)
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
                    ;;necessarily `owner-konto`, the account that will own the score and vault.
                    ;;A vault operator may stake a token somebody else issued. Derived, not assumed.
                    (stake-asset-owner:string
                        (ref-AQP::URC_AqpOwnerKontoFromClassAndAsset GV|POOL_CLASS_TF stake-dptf-id))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (ref-SCR::C_IssueTrueFungibleScore
                                patron owner-konto score-name GV|PRECISION GV|MX_FROZEN)
                            (ref-AQP::C_Issue patron stake-asset-owner pool-name stake-dptf-id GV|POOL_CLASS_TF)
                            (ref-AQP::C_AddScore patron stake-asset-owner pool-id score-id)
                            (ref-FVT::C_Issue
                                patron fvt-name owner-konto GV|FVT_CLASS_VAULT GV|COMMON_BAR)
                            ;;The FVT's executor here IS `owner-konto` -- C_Issue two lines up
                            ;;makes that account the vault's owner, so it is derived, not assumed.
                            (ref-FVT::C_AddScoreEntity
                                patron owner-konto fvt-id GV|SCORE_ENTITY_SCORE score-id)
                            (ref-FVT::C_AddRewardLink
                                patron owner-konto fvt-id reward-dptf-id false GV|COMMON_BAR)
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
        (patron:string injector:string fvt-id:string reward-dptf-id:string amount:decimal duration:integer)
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
                    (ref-FVT::CC_InjectStream patron injector fvt-id reward-dptf-id amount duration)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Successfully streamed {} {} into FVT {} over {}s." [amount reward-dptf-id fvt-id duration])
            )
        )
    )
    (defun AQP-FVT|CC_Inject:string
        (patron:string injector:string fvt-id:string reward-dptf-id:string amount:decimal)
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
                    (ref-FVT::CC_Inject patron injector fvt-id reward-dptf-id amount)
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
        (patron:string injector:string fvt-id:string reward-dptf-id:string amount:decimal)
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
                    (ref-FVT::CC_InjectFinalize patron injector fvt-id reward-dptf-id amount)
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
        (patron:string injector:string fvt-id:string reward-dptf-id:string amount:decimal)
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
                        (r:string (ref-MTX-AQP::C_2|Inject patron injector fvt-id reward-dptf-id amount))
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
        (patron:string fvt-ids:[string])
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
                    (ref-FVT::CC_UnstaleMyScores patron fvt-ids)
                )
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (format "Refreshed your stale scores across {} FVT(s)." [(length fvt-ids)])
            )
        )
    )
    (defun AQP-FVT|CC_Collect:string
        (patron:string collector:string fvt-id:string score-entity-type:integer score-entity-id:string reward-dptf-id:string)
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
                    (ref-FVT::CC_Collect patron collector fvt-id score-entity-type score-entity-id reward-dptf-id)
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
                        pool-id executor executor collectable-id true
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
    (defun A_RegisterAssetToLaunchpad (patron:string asset-id:string fungibility:[bool]))
    (defun A_ToggleOpenForBusiness (asset-id:string toggle:bool))
    (defun A_DefinePrice (asset-id:string price:object))
    (defun A_ToggleRetrieval (asset-id:string toggle:bool))
    ;;
    ;;  [C]
    ;;
    (defun DEMIPAD|C_Deposit (patron:string donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal))
    ;;
    (defun DEMIPAD|C_Withdraw (patron:string asset-id:string type:integer destination:string))
    ;;
    (defun DEMIPAD|C_FuelTrueFungible (patron:string client:string asset-id:string amount:decimal))
    (defun DEMIPAD|C_FuelOrtoFungible (patron:string client:string asset-id:string nonces:[integer]))
    (defun DEMIPAD|C_FuelSemiFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))
    (defun DEMIPAD|C_FuelNonFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))
    (defun DEMIPAD|C_RetrieveTrueFungible (patron:string client:string asset-id:string amount:decimal))
    (defun DEMIPAD|C_RetrieveOrtoFungible (patron:string client:string asset-id:string nonces:[integer]))
    (defun DEMIPAD|C_RetrieveSemiFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))
    (defun DEMIPAD|C_RetrieveNonFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer]))

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
    (defun A_RegisterAssetToLaunchpad (patron:string asset-id:string fungibility:[bool])
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
                (ref-DEMIPAD::A_RegisterAssetToLaunchpad patron asset-id fungibility)
                ;;Reconciles two audits' DeployAccount hardening (dptf-dpof #N2 + DPDC #35M):
                ;; #N2: lpad is DEMIPAD's own system smart account (not patron's) — tf/of use the ADMIN
                ;;   variant (TS01-A, no ownership check on <account>); the self-service C_ variant now
                ;;   requires the caller to own <account>, which they don't for lpad.
                ;; #35M: the public DPSF|C_DeployAccount/DPNF|C_DeployAccount Talos wrappers were REMOVED
                ;;   (any signer could force any account onto any collection); sf/nf now call
                ;;   DPDC::XBv_DeployAccountSFT/NFT directly, module-to-module — the pattern every
                ;;   legitimate internal caller (DPDC-C/DPDC-F/DPDC-R/DPDC-S) already uses.
                (cond
                    ((= fungibility tf) (ref-TS01-A::DPTF|A_DeployAccount patron asset-id lpad))
                    ((= fungibility of) (ref-TS01-A::DPOF|A_DeployAccount patron asset-id lpad))
                    ((= fungibility sf) (ref-DPDC::XBv_DeployAccountSFT lpad asset-id f f f f f f f f f f f))
                    ((= fungibility nf) (ref-DPDC::XBv_DeployAccountNFT lpad asset-id f f f f f f f f f f))
                    true
                )
            )
        )
    )
    (defun A_ToggleOpenForBusiness (asset-id:string toggle:bool)
        @doc "Toggle Open For Bussines. Must be on to acquire Assets"
        (with-capability (P|TALOS-SUMMONER)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                )
                (ref-DEMIPAD::A_ToggleOpenForBusiness asset-id toggle)
            )
        )
    )
    (defun A_DefinePrice (asset-id:string price:object)
        @doc "Updates Price Object for an Asset"
        (with-capability (P|TALOS-SUMMONER)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                )
                (ref-DEMIPAD::A_DefinePrice asset-id price)
            )
        )
    )
    (defun A_ToggleRetrieval (asset-id:string toggle:bool)
        @doc "Retrieval ON allows Asset Owners to retrieve their Asssets that still exist on the Launchpad"
        (with-capability (P|TALOS-SUMMONER)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                )
                (ref-DEMIPAD::A_ToggleRetrieval asset-id toggle)
            )
        )
    )
    (defun DEMIPAD|C_Deposit (patron:string donor:string asset-id:string amount-in-dollars:decimal type:integer direct-injection:bool max-cost:decimal)
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
                    (sd:string (ref-I|OURONET::OI|UC_ShortAccount donor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DEMIPAD::C_Deposit donor asset-id amount-in-dollars type direct-injection max-cost)
                )
                (format "Succesfuly deposited {} $ worth against {} into Demipad from {}." [amount-in-dollars asset-id sd])
            )
        )
    )
    ;;
    (defun DEMIPAD|C_Withdraw (patron:string asset-id:string type:integer destination:string)
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
                (ref-DEMIPAD::C_Withdraw patron asset-id type destination)
                (format "Succesfuly withdrawn {} {} from Demipad to {}." [retrieval-amount working-id sd])
            )
        )
    )
    ;;
    (defun DEMIPAD|C_FuelTrueFungible (patron:string client:string asset-id:string amount:decimal)
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                )
                (ref-DEMIPAD::C_TransmitTrueFungible patron client asset-id amount true)
            )
        )
    )
    (defun DEMIPAD|C_FuelOrtoFungible (patron:string client:string asset-id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                )
                (ref-DEMIPAD::C_TransmitOrtoFungible patron client asset-id nonces true)
            )
        )
    )
    (defun DEMIPAD|C_FuelSemiFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount client))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DEMIPAD::C_TransmitSemiFungibles client asset-id nonces amounts true)
                )
                (format "Succesfuly fueled {} Nonces {} with Amounts {} to Demiourgos Launchpad from Account {}" [asset-id nonces amounts c])
            )
        )
    )
    (defun DEMIPAD|C_FuelNonFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount client))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DEMIPAD::C_TransmitNonFungibles client asset-id nonces amounts true)
                )
                (format "Succesfuly fueled {} Nonces {} with Amounts {} to Demiourgos Launchpad from Account {}" [asset-id nonces amounts c])
            )
        )
    )
    ;;
    (defun DEMIPAD|C_RetrieveTrueFungible (patron:string client:string asset-id:string amount:decimal)
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                )
                (ref-DEMIPAD::C_TransmitTrueFungible patron client asset-id amount false)
            )
        )
    )
    (defun DEMIPAD|C_RetrieveOrtoFungible (patron:string client:string asset-id:string nonces:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                )
                (ref-DEMIPAD::C_TransmitOrtoFungible patron client asset-id nonces false)
            )
        )
    )
    (defun DEMIPAD|C_RetrieveSemiFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount client))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DEMIPAD::C_TransmitSemiFungibles client asset-id nonces amounts false)
                )
                (format "Succesfuly retrieved {} Nonces {} with Amounts {} from Demiourgos Launchpad to Account {}" [asset-id nonces amounts c])
            )
        )
    )
    (defun DEMIPAD|C_RetrieveNonFungible (patron:string client:string asset-id:string nonces:[integer] amounts:[integer])
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                    (c:string (ref-I|OURONET::OI|UC_ShortAccount client))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-DEMIPAD::C_TransmitNonFungibles client asset-id nonces amounts false)
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

;; ===== 2_CITIZEN/7_Launchpad/1_Spark/01_Spark.pact =================
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface SparksV2




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
    ;;
    ;;  [UR]
    ;;
    (defun UR_SparkID:string ())
    (defun UR_IzOpenForBusiness:bool ())
    (defun UR_FrozenSparkID:string ())
    (defun UR_Sparks (account:string))
    ;;
    ;;  [URC]
    ;;
    (defun URC_GetMaxBuy:integer (account:string native:bool))
    (defun URC_SparkCost:decimal ())
    (defun URC_SparkRedemptionCost:decimal ())
    (defun URC_AccountRedemptionAmount:decimal (account:string))
    (defun URC_Acquire:[string] (buyer:string amount:integer iz-native:bool slippage:decimal))
    ;;
    ;;  [URCi] / [INFO]  (pure-citizen cost preview: Sigma of the sovereign Talos ops' IGNIS)
    ;;
    (defun URCi_BuySparks:decimal (buyer:string sparks-amount:integer iz-native:bool))
    (defun INFO_BuySparks:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string sparks-amount:integer iz-native:bool))
    (defun URCi_RedeemSparks:decimal (redemption-payer:string account-to-redeem:string redemption-quantity:decimal))
    (defun INFO_RedeemSparks:object{OuronetInfoV2.ClientInfo} (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal))
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire (buyer:string amount:integer iz-native:bool))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_BuySparks (patron:string buyer:string sparks-amount:integer iz-native:bool max-cost:decimal))
    (defun C_RedemAllSparks (patron:string redemption-payer:string account-to-redeem:string))
    (defun C_CustomRedemAllSparks (patron:string redemption-payer:string account-to-redeem:string custom-stoa-pid:decimal))
    (defun C_RedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal))
    (defun C_CustomRedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal custom-stoa-pid:decimal))

)
(module DEMIPAD-SPARK GOV






    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SparksV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_SPARK                              (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SPARK_ADMIN)))
    (defcap GOV|SPARK_ADMIN ()                          (enforce-guard GOV|MD_SPARK))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|DEMIPAD|SC_NAME ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
            )
            (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME)
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
    (defcap P|SPARK|CALLER ()
        true
    )
    (defcap P|PAD-SPARK|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|SPARK|CALLER))
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
        (with-capability (GOV|SPARK_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SPARK_ADMIN)
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
        (with-capability (GOV|SPARK_ADMIN)
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
        (with-capability (GOV|SPARK_ADMIN)
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
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|VST:module{OuronetPolicyV2} VST)
                (ref-P|DPAD:module{OuronetPolicyV2} DEMIPAD)
                (mg:guard (create-capability-guard (P|SPARK|CALLER)))
            )
            (ref-P|DPAD::P|A_Add
                "SPARK|RemoteGov"
                (create-capability-guard (P|PAD-SPARK|REMOTE-GOV))
            )
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|VST::P|A_AddIMP mg)
            (ref-P|DPAD::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst DEMIPAD|SC_NAME                           (GOV|DEMIPAD|SC_NAME))
    (defconst SPARK|INFO                                (CT_Info))
    (defconst BAR                                       (CT_Bar))
    ;;{3.2}  schemas
    ;;
    (defschema SPARK|PropertiesSchema
        spark-id:string
    )
    ;;{3.3}  tables
    (deftable SPARK|T|Properties:{SPARK|PropertiesSchema})

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap SPARK|C>BUY (sparks-amount:integer)
        @event
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (spark-id:string (UR_SparkID))
                (remaining-supply:decimal (ref-DPTF::UR_AccountSupply spark-id DEMIPAD|SC_NAME))
                (amount:decimal (dec sparks-amount))
            )
            (enforce (<= amount remaining-supply) "Remaining Amount surpassed!")
            (compose-capability (P|PAD-SPARK|REMOTE-GOV))
            (compose-capability (P|SECURE-CALLER))
        )
    )
    (defcap SPARK|C>REEDEM-ALL (account-to-redeem:string)
        @event
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (spark-id:string (UR_SparkID))
                (supply:decimal (ref-DPTF::UR_AccountSupply spark-id account-to-redeem))
            )
            (compose-capability (SPARK|C>X_REEDEM account-to-redeem supply))
        )
    )
    (defcap SPARK|C>REEDEM-FEW (account-to-redeem:string redemption-quantity:decimal)
        @event
        (compose-capability (SPARK|C>X_REEDEM account-to-redeem redemption-quantity))
    )
    (defcap SPARK|C>X_REEDEM (account-to-redeem:string redemption-quantity:decimal)
        (compose-capability (GOV|SPARK_ADMIN))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (spark-id:string (UR_SparkID))
                (supply:decimal (ref-DPTF::UR_AccountSupply spark-id account-to-redeem))
            )
            (ref-DPTF::CAP_Owner spark-id)
            (enforce 
                (and
                    (> redemption-quantity 0.0)
                    (<= redemption-quantity supply)
                )
                "Invalid Redemmption Amount"
            )
            (compose-capability (P|SECURE-CALLER))
            (compose-capability (P|PAD-SPARK|REMOTE-GOV))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Info ()                                   (at 0 ["spark-data-key"]))
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun UR_SparkID:string ()
        (at "spark-id" (read SPARK|T|Properties SPARK|INFO ["spark-id"]))
    )
    (defun UR_BoostPromille:decimal ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
            )
            (at "boost" (ref-DEMIPAD::UR_Price (UR_SparkID)))
        )
    )
    (defun UR_IzOpenForBusiness:bool ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
            )
            (ref-DEMIPAD::UR_OpenForBusiness (UR_SparkID))
        )
    )
    (defun UR_FrozenSparkID:string ()
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DPTF::UR_Frozen (UR_SparkID))
        )
    )
    (defun UR_Sparks (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (spark-id:string (UR_SparkID))
                (f-spark-id:string (UR_FrozenSparkID))
            )
            {"spark-id"         : spark-id
            ,"f-spark-id"       : f-spark-id
            ,"spark-supply"     : (ref-DPTF::UR_AccountSupply spark-id account)
            ,"f-spark-supply"   : (ref-DPTF::UR_AccountSupply f-spark-id account)
            ;;
            ,"iz-sale"          : (UR_IzOpenForBusiness)
            ,"boost-promile"    : (UR_BoostPromille)
            ;;
            ,"left-for-sale"    : (ref-DPTF::UR_AccountSupply spark-id DEMIPAD|SC_NAME)
            ,"sparks-supply"    : (ref-DPTF::UR_Supply spark-id)
            ,"f-sparks-supply"  : (ref-DPTF::UR_Supply f-spark-id)
            ;;
            ,"stoa-spark-cost"   : (URC_SparkCost)
            ,"redemption-value" : (URC_SparkRedemptionCost)
            ;;
            ,"native-max"       : (URC_GetMaxBuy account true)
            ,"wstoa-max"         : (URC_GetMaxBuy account false)
            ;;
            ,"account-ignis"    : (ref-DPTF::UR_AccountSupply (ref-DALOS::UR_IgnisID) account)
            ,"ignis-collection" : (ref-DALOS::UR_VirtualToggle)}
        )
    )
    (defun URC_GetMaxBuy:integer (account:string native:bool)
        @doc "Returns the maximum amount of Tokens that can still be bought \
            \ Considering the amount left, and the User Funds"
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (k-account:string (ref-DALOS::UR_AccountStoa account))
                (wstoa:string (ref-DALOS::UR_WrappedStoaID))
                (spark-id:string (UR_SparkID))
                (spark-price:decimal (at "pid" (ref-DEMIPAD::UR_Price spark-id)))
                (still-for-sale:decimal (ref-DPTF::UR_AccountSupply spark-id DEMIPAD|SC_NAME))
                ;;
                (client-stoa-supply:decimal
                    (if native
                        (ref-coin::get-balance k-account)
                        (ref-DPTF::UR_AccountSupply wstoa account)
                    )
                )
                (client-stoa-value-in-dollarz:decimal (floor (* client-stoa-supply stoa-pid) 2))
                (can-buy-with-client-supply:decimal (floor (/ client-stoa-value-in-dollarz spark-price)))
            )
            (floor
                (if (<= can-buy-with-client-supply still-for-sale)
                    can-buy-with-client-supply
                    still-for-sale
                )
            )
        )
    )
    (defun URC_SparkCost:decimal ()
        @doc "Returns the amount of STOA that is needed to pay for one Token"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (spark-id:string (UR_SparkID))
                (spark-price:decimal (at "pid" (ref-DEMIPAD::UR_Price spark-id)))
            )
            (floor (/ spark-price stoa-pid) stoa-prec)
        )
    )
    (defun URC_SparkRedemptionCost:decimal ()
        @doc "Returns the amount of STOA|WSTOA a single Token can be redeemed for."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                (boost:decimal (UR_BoostPromille))
            )
            (floor (/ (+ 1.0 (/ boost 1000.0)) stoa-pid) stoa-prec)
        )
    )
    (defun URC_CustomSparkRedemptionCost:decimal (custom-stoa-pid:decimal)
        @doc "Returns the amount of STOA|WSTOA a single Token can be redeemed for."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (boost:decimal (UR_BoostPromille))
            )
            (floor (/ (+ 1.0 (/ boost 1000.0)) custom-stoa-pid) stoa-prec)
        )
    )
    (defun URC_AccountRedemptionAmount:decimal (account:string)
        @doc "Returns Account Redemption Amount"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (spark-id:string (UR_SparkID))
                (supply:decimal (ref-DPTF::UR_AccountSupply spark-id account))
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (rc:decimal (URC_SparkRedemptionCost))
            )
            (floor (* supply rc) stoa-prec)
        )
    )
    (defun URC_SparkAmountCosts:object{DemiourgosLaunchpadV2.Costs} (amount:integer)
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (spark-id:string (UR_SparkID))
                (spark-price:decimal (at "pid" (ref-DEMIPAD::UR_Price spark-id)))
            )
            (ref-DEMIPAD::UDC_Costs
                (* (dec amount) spark-price)
                (floor (* (/ spark-price stoa-pid) (dec amount)) stoa-prec)
            )
        )
    )
    (defun URCi_BuySparks:decimal (buyer:string sparks-amount:integer iz-native:bool)
        @doc "Pure-citizen IGNIS cost preview for C_BuySparks = Sigma of the two SOVEREIGN Talos ops' \
            \ IGNIS (each self-collects): DEMIPAD deposit + DPTF Sparks-out transfer. The deposit is \
            \ amount-independent; the transfer cost depends only on the DPTF fee class of Sparks."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (spark-id:string (UR_SparkID))
                (pid:decimal (at "pid" (URC_SparkAmountCosts sparks-amount)))
                (type:integer (if iz-native 0 1))
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                   (ref-DEMIPAD::URCi_Deposit buyer spark-id pid type false))
               (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                   (ref-TFT::URCi_Transfer spark-id DEMIPAD|SC_NAME buyer (dec sparks-amount))))
        )
    )
    (defun INFO_BuySparks:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string sparks-amount:integer iz-native:bool)
        @doc "Cost preview for the SPARK|C_BuySparks pure-citizen buy (sole gas-funded path = the \
            \ TS02-CPAD Talos wrapper). IGNIS = URCi_BuySparks (Sigma of the two Talos ops). Launchpad \
            \ ops carry NO protocol STOA fee; the ACQUISITION cost (dollar pid + STOA wstoa) is declared \
            \ in the description as the good being bought, not a fee-to-execute (protocol stoa = none)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (spark-id:string (UR_SparkID))
                (costs:object{DemiourgosLaunchpadV2.Costs} (URC_SparkAmountCosts sparks-amount))
                (pid:decimal (at "pid" costs))
                (wstoa:decimal (at "wstoa" costs))
                (pay:string (if iz-native "Native STOA" "OWS (Wrapped STOA)"))
                (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Buy {} {} Sparks for {} (pure-citizen, Sigma-billed)." [sparks-amount spark-id sb])
                  (format "Acquisition cost: {} $ paid as {} {} (not a protocol fee)." [pid wstoa pay])
                  "Executes via TS02-CPAD.SPARK|C_BuySparks (the sole gas-funded path)." ]
                [ (format "Acquired {} {} Sparks." [sparks-amount spark-id]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_BuySparks buyer sparks-amount iz-native))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URCi_RedeemSparks:decimal (redemption-payer:string account-to-redeem:string redemption-quantity:decimal)
        @doc "Pure-citizen IGNIS cost preview for C_Redem*Sparks = Sigma of the six SOVEREIGN Talos ops' \
            \ IGNIS (each self-collects): wSTOA transfer + freeze + wipe + unfreeze + remint + VST re-freeze. \
            \ Per-op costs are fee-class based; fed the same redemption-quantity the exec receives."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-VST:module{VestingV2} VST)
                (spark-id:string (UR_SparkID))
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (redemption-value:decimal (floor (* (URC_SparkRedemptionCost) redemption-quantity) 12))
            )
            (fold (+) 0.0
                [ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-TFT::URCi_Transfer wstoa-id redemption-payer account-to-redeem redemption-value))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_ToggleFreezeAccount spark-id))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_WipeSlim spark-id))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_ToggleFreezeAccount spark-id))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_Mint spark-id DEMIPAD|SC_NAME false))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-VST::URCi_Freeze DEMIPAD|SC_NAME account-to-redeem spark-id redemption-quantity)) ])
        )
    )
    (defun INFO_RedeemSparks:object{OuronetInfoV2.ClientInfo} (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal)
        @doc "Cost preview for the SPARK|C_RedemAll/FewSparks pure-citizen redeem (sole gas-funded path = \
            \ the TS02-CPAD Talos wrapper). IGNIS = URCi_RedeemSparks (Sigma of the six Talos ops). No \
            \ protocol STOA fee; the redeem RETURNS wSTOA to the account (a refund, not a cost)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (spark-id:string (UR_SparkID))
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (redemption-value:decimal (floor (* (URC_SparkRedemptionCost) redemption-quantity) 12))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account-to-redeem))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Redeem {} {} from {} (pure-citizen, Sigma-billed)." [redemption-quantity spark-id sa])
                  (format "Returns {} {} to the account (a refund, not a cost)." [redemption-value wstoa-id]) ]
                [ (format "Redeemed {} {} for {} {}." [redemption-quantity spark-id redemption-value wstoa-id]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_RedeemSparks redemption-payer account-to-redeem redemption-quantity))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_Acquire:[string]
        (buyer:string amount:integer iz-native:bool slippage:decimal)
        @doc "Variant 1 (with slippage) — coin.TRANSFER caps the UI signs, padded by (1 + slippage/100)."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (asset-id:string (UR_SparkID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_SparkAmountCosts amount)))
            )
            (ref-DEMIPAD::URC_Acquire buyer asset-id pid type slippage)
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire
        (buyer:string amount:integer iz-native:bool)
        @doc "Variant 2 (slippage off) — installs the coin.TRANSFER caps in-code at the live price."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (asset-id:string (UR_SparkID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_SparkAmountCosts amount)))
            )
            (ref-DEMIPAD::CAP_Acquire buyer asset-id pid type)
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 2 — SECURE
    (defun XI_RedeemSparks 
        (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal)
        (require-capability (SECURE))
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                (ref-TS01-C2:module{TalosStageOne_ClientTwoV2} TS01-C2)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                ;;
                (spark-id:string (UR_SparkID))
                (spark-redemption-cost:decimal (URC_SparkRedemptionCost))
                (redemption-value:decimal (floor (* spark-redemption-cost redemption-quantity) stoa-prec))
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (sa-atr:string (ref-I|OURONET::OI|UC_ShortAccount account-to-redeem))
            )
            ;;PURE CITIZEN: six SOVEREIGN Talos ops, each self-collecting IGNIS on patron (Sigma-billed).
            ;;1]Move Wrapped Stoa to Target
            (ref-TS01-C1::DPTF|C_Transfer patron wstoa-id redemption-payer account-to-redeem redemption-value true)
            ;;2]Freeze <account-to-redeem>
            (ref-TS01-C1::DPTF|C_ToggleFreezeAccount patron spark-id account-to-redeem true)
            ;;3]Partial Wipe <spark-id>
            (ref-TS01-C1::DPTF|C_WipeSlim patron spark-id account-to-redeem redemption-quantity)
            ;;4]Unfreeze <account-to-redeem>
            (ref-TS01-C1::DPTF|C_ToggleFreezeAccount patron spark-id account-to-redeem false)
            ;;5]Remint wiped amount to <DEMIPAD|SC_NAME>
            (ref-TS01-C1::DPTF|C_Mint patron spark-id DEMIPAD|SC_NAME redemption-quantity false)
            ;;6]Freeze it back to <account-to-redeem>
            (ref-TS01-C2::VST|C_Freeze patron DEMIPAD|SC_NAME account-to-redeem spark-id redemption-quantity)
            (format "Succesfully Redeemed {} {} for {} {} on Account {}"
                [redemption-quantity spark-id redemption-value wstoa-id sa-atr]
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_CustomRedeemSparks 
        (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal custom-stoa-pid:decimal)
        (require-capability (SECURE))
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                (ref-TS01-C2:module{TalosStageOne_ClientTwoV2} TS01-C2)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                ;;
                (spark-id:string (UR_SparkID))
                (spark-redemption-cost:decimal (URC_CustomSparkRedemptionCost custom-stoa-pid))
                (redemption-value:decimal (floor (* spark-redemption-cost redemption-quantity) stoa-prec))
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (sa-atr:string (ref-I|OURONET::OI|UC_ShortAccount account-to-redeem))
            )
            ;;PURE CITIZEN: six SOVEREIGN Talos ops, each self-collecting IGNIS on patron (Sigma-billed).
            ;;1]Move Wrapped Stoa to Target
            (ref-TS01-C1::DPTF|C_Transfer patron wstoa-id redemption-payer account-to-redeem redemption-value true)
            ;;2]Freeze <account-to-redeem>
            (ref-TS01-C1::DPTF|C_ToggleFreezeAccount patron spark-id account-to-redeem true)
            ;;3]Partial Wipe <spark-id>
            (ref-TS01-C1::DPTF|C_WipeSlim patron spark-id account-to-redeem redemption-quantity)
            ;;4]Unfreeze <account-to-redeem>
            (ref-TS01-C1::DPTF|C_ToggleFreezeAccount patron spark-id account-to-redeem false)
            ;;5]Remint wiped amount to <DEMIPAD|SC_NAME>
            (ref-TS01-C1::DPTF|C_Mint patron spark-id DEMIPAD|SC_NAME redemption-quantity false)
            ;;6]Freeze it back to <account-to-redeem>
            (ref-TS01-C2::VST|C_Freeze patron DEMIPAD|SC_NAME account-to-redeem spark-id redemption-quantity)
            (format "Succesfully Redeemed {} {} for {} {} on Account {}"
                [redemption-quantity spark-id redemption-value wstoa-id sa-atr]
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun C_BuySparks (patron:string buyer:string sparks-amount:integer iz-native:bool max-cost:decimal)
        @doc "PURE CITIZEN buy. Composes two SOVEREIGN Talos ops — DEMIPAD|C_Deposit (buyer STOA -> \
            \ Launchpad) then DPTF|C_Transfer (Sparks Launchpad -> buyer) — each self-collecting IGNIS \
            \ on <patron>. A citizen cannot fold cumulators (no permission for the bare uncollected \
            \ core funcs), so IGNIS is billed Sigma-wise (once per op). <max-cost> is the buyer's dollar \
            \ slippage ceiling (sentinel < 0 = slippage off). Preview: URCi_BuySparks / INFO_BuySparks."
        (with-capability (SPARK|C>BUY sparks-amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TS02-DPAD:module{TalosStageTwo_DemiPadV1} TS02-DPAD)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    ;;
                    (spark-id:string (UR_SparkID))
                    (costs:object{DemiourgosLaunchpadV2.Costs} (URC_SparkAmountCosts sparks-amount))
                    (pid:decimal (at "pid" costs))
                    (type:integer (if iz-native 0 1))
                    (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
                )
                ;;1] SOVEREIGN deposit Talos op — buyer's STOA into the Launchpad; self-collects IGNIS on patron
                (ref-TS02-DPAD::DEMIPAD|C_Deposit patron buyer spark-id pid type false max-cost)
                ;;2] SOVEREIGN DPTF transfer Talos op — Sparks from the Launchpad SC to the buyer; self-collects IGNIS
                (ref-TS01-C1::DPTF|C_Transfer patron spark-id DEMIPAD|SC_NAME buyer (dec sparks-amount) true)
                (format "User {} succesfuly acquired {} {} Tokens" [sb sparks-amount spark-id])
            )
        )
    )
    (defun C_RedemAllSparks (patron:string redemption-payer:string account-to-redeem:string)
        (with-capability (SPARK|C>REEDEM-ALL account-to-redeem)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (spark-id:string (UR_SparkID))
                    (supply:decimal (ref-DPTF::UR_AccountSupply spark-id account-to-redeem))
                )
                (XI_RedeemSparks patron redemption-payer account-to-redeem supply)
            )
        )
    )
    (defun C_CustomRedemAllSparks (patron:string redemption-payer:string account-to-redeem:string custom-stoa-pid:decimal)
        (with-capability (SPARK|C>REEDEM-ALL account-to-redeem)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (spark-id:string (UR_SparkID))
                    (supply:decimal (ref-DPTF::UR_AccountSupply spark-id account-to-redeem))
                )
                (XI_CustomRedeemSparks patron redemption-payer account-to-redeem supply custom-stoa-pid)
            )
        )
    )
    (defun C_RedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal)
        (with-capability (SPARK|C>REEDEM-FEW account-to-redeem redemption-quantity)
            (XI_RedeemSparks patron redemption-payer account-to-redeem redemption-quantity)
        )
    )
    (defun C_CustomRedemFewSparks (patron:string redemption-payer:string account-to-redeem:string redemption-quantity:decimal custom-stoa-pid:decimal)
        (with-capability (SPARK|C>REEDEM-FEW account-to-redeem redemption-quantity)
            (XI_CustomRedeemSparks patron redemption-payer account-to-redeem redemption-quantity custom-stoa-pid)
        )
    )

)

;; --- tables for 01_Spark.pact (3 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table SPARK|T|Properties)

;; ===== 2_CITIZEN/7_Launchpad/2_Snakes/02_Snakes.pact ===============
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface SaleSnakesV2




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
    ;;
    ;;  [UR]
    ;;
    (defun UR_AssetID ())
    (defun UR_DollarSharePrice:decimal ())
    (defun UR_NonceSaleAvailability:integer (nonce:integer))
    ;;
    ;;  [URC]
    ;;
    (defun URC_NonceValueInShares:integer (nonce:integer))
    (defun URC_ShareCosts:object{DemiourgosLaunchpadV2.Costs} ())
    (defun URC_NonceCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer))
    (defun URC_NonceAmountCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer amount:integer))
    (defun URC_Acquire:[string] (buyer:string nonce:integer amount:integer iz-native:bool slippage:decimal))
    ;;
    ;;  [URCi] / [INFO]  (pure-citizen cost preview: Sigma of the sovereign Talos ops' IGNIS)
    ;;
    (defun URCi_Acquire:decimal (buyer:string nonce:integer amount:integer iz-native:bool))
    (defun INFO_Acquire:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string nonce:integer amount:integer iz-native:bool))
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_AcquisitionNonce (nonce:integer))
    (defun CAP_Acquire (buyer:string nonce:integer amount:integer iz-native:bool))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A+C]
    ;;
    (defun A_UpdateSharePrice (price:decimal))
    (defun C_Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal))

)
(module DEMIPAD-SNAKES GOV
    @doc "Module defining the Sale Mechanics for Demiourgos Share Holder Collection"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SaleSnakesV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_SNAKES                             (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SNAKES_ADMIN)))
    (defcap GOV|SNAKES_ADMIN ()                         (enforce-guard GOV|MD_SNAKES))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|DEMIPAD|SC_NAME ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
            )
            (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME)
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
    (defcap P|SNAKES|CALLER ()
        true
    )
    (defcap P|SNAKES|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|SNAKES|CALLER))
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
        (with-capability (GOV|SNAKES_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SNAKES_ADMIN)
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
        (with-capability (GOV|SNAKES_ADMIN)
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
        (with-capability (GOV|SNAKES_ADMIN)
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
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (ref-P|DPAD:module{OuronetPolicyV2} DEMIPAD)
                (mg:guard (create-capability-guard (P|SNAKES|CALLER)))
            )
            (ref-P|DPAD::P|A_Add
                "SNAKES|RemoteGov"
                (create-capability-guard (P|SNAKES|REMOTE-GOV))
            )
            (ref-P|DPDC-T::P|A_AddIMP mg)
            (ref-P|DPAD::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst DEMIPAD|SC_NAME                           (GOV|DEMIPAD|SC_NAME))
    (defconst SNAKES|INFO                               (CT_Info))
    (defconst BAR                                       (CT_Bar))
    ;;{3.2}  schemas
    ;;
    (defschema SNAKES|PropertiesSchema
        asset-id:string
    )
    ;;{3.3}  tables
    (deftable SNAKES|T|Properties:{SNAKES|PropertiesSchema})

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap SNAKES|C>INITIALISE ()
        @event
        (compose-capability (GOV|SNAKES_ADMIN))
    )
    (defcap SNAKES|ACQUIRE (nonce:integer amount:integer)
        @event
        (let
            (
                (available-supply-to-acquire:integer (UR_NonceSaleAvailability nonce))
            )
            ;;nonce validity FIRST, so an unsellable nonce is named as such rather than reported as
            ;;a stock shortage it can never recover from. Order matters: UR_NonceSaleAvailability
            ;;answers 0 for an unknown nonce, so the supply check below would otherwise absorb it.
            (UEV_AcquisitionNonce nonce)
            (enforce (<= amount available-supply-to-acquire) "Insufficient Assets for Acquisiton!")
            (compose-capability (P|SNAKES|CALLER))
            (compose-capability (P|SNAKES|REMOTE-GOV))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Info ()                                   (at 0 ["Shareholders"]))
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun UR_AssetID ()
        (at "asset-id" (read SNAKES|T|Properties SNAKES|INFO ["asset-id"]))
    )
    (defun UR_DollarSharePrice:decimal ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
            )
            (at "price-per-share-in-dollars" (ref-DEMIPAD::UR_Price (UR_AssetID)))
        )
    )
    (defun UR_NonceSaleAvailability:integer (nonce:integer)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                (asset:string (UR_AssetID))
            )
            (ref-DPDC::UR_AccountNonceSupply lpad asset true nonce)
        )
    )
    (defun URC_NonceValueInShares:integer (nonce:integer)
        (if (= nonce 1)
            1
            (let
                (
                    (ref-EQUITY:module{EquityV2} EQUITY)
                    (asset:string (UR_AssetID))
                    (tier:integer (- nonce 1))
                )
                (ref-EQUITY::URC_SingleSharePerMillions asset tier)
            )
        )
    )
    (defun URC_ShareCosts:object{DemiourgosLaunchpadV2.Costs} ()
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (share-pid:decimal (UR_DollarSharePrice))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                share-pid
                (floor (/ share-pid stoa-pid) wstoa-prec)
            )
        )
    )
    (defun URC_NonceCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (share-costs:object{DemiourgosLaunchpadV2.Costs} (URC_ShareCosts))
                (nonce-value-in-shares:integer (URC_NonceValueInShares nonce))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                (floor (* (at "pid" share-costs) (dec nonce-value-in-shares)) 2)
                (floor (* (at "wstoa" share-costs) (dec nonce-value-in-shares)) wstoa-prec)
            )
        )
    )
    (defun URC_NonceAmountCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer amount:integer)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (nonce-costs:object{DemiourgosLaunchpadV2.Costs} (URC_NonceCosts nonce))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                (floor (* (at "pid" nonce-costs) (dec amount)) 2)
                (floor (* (at "wstoa" nonce-costs) (dec amount)) wstoa-prec)
            )
        )
    )
    (defun URCi_Acquire:decimal (buyer:string nonce:integer amount:integer iz-native:bool)
        @doc "Pure-citizen IGNIS cost preview for C_Acquire = Sigma of the two SOVEREIGN Talos ops' \
            \ IGNIS (each self-collects): DEMIPAD deposit + DPDC-T SFT nonce transfer. Amount-independent \
            \ deposit; the transfer cost depends only on the collectable fee class."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (asset:string (UR_AssetID))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
                (type:integer (if iz-native 0 1))
            )
            (+ (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-DEMIPAD::URCi_Deposit buyer asset pid type false))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-DPDC-T::URCi_MultiTransferCumulator [asset] [true] DEMIPAD|SC_NAME buyer [[nonce]] [[amount]])))
               ;;MISSING LEG FIXED (2026-09-14). The Sigma counted the deposit and the transfer GAS but
               ;;not the IGNIS ROYALTY. `DPDC|C_MultiTransfer` runs `C_IgnisRoyaltyCollector patron ...`
               ;;before its own collect, and that pays the collection creator OUT OF THE PATRON — so a
               ;;buyer of a royalty-bearing nonce is charged more than this preview quoted. Measured
               ;;89.002 quoted against 89.004 charged on a 2-share buy (0.001/share).
               ;;The `(if virtual-gas-zero 0.0 ...)` mirrors the collector's own short-circuit, so the
               ;;preview stays correct when virtual gas is switched off.
               (if (ref-IGNIS::URC_IsVirtualGasZero)
                   0.0
                   (ref-DPDC-T::URC_SummedIgnisRoyalty DEMIPAD|SC_NAME asset true [nonce] [amount])))
        )
    )
    (defun INFO_Acquire:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string nonce:integer amount:integer iz-native:bool)
        @doc "Cost preview for the SNAKES|C_Acquire pure-citizen buy (sole gas-funded path = the \
            \ TS02-CPAD Talos wrapper). IGNIS = URCi_Acquire (Sigma of the two Talos ops). Launchpad ops \
            \ carry NO protocol STOA fee; the ACQUISITION cost (dollar pid + STOA wstoa) is declared in \
            \ the description as the good bought, not a fee-to-execute (protocol stoa = none)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (asset:string (UR_AssetID))
                (costs:object{DemiourgosLaunchpadV2.Costs} (URC_NonceAmountCosts nonce amount))
                (pid:decimal (at "pid" costs))
                (wstoa:decimal (at "wstoa" costs))
                (pay:string (if iz-native "Native STOA" "OWS (Wrapped STOA)"))
                (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Acquire {} of {} nonce {} for {} (pure-citizen, Sigma-billed)." [amount asset nonce sb])
                  (format "Acquisition cost: {} $ paid as {} {} (not a protocol fee)." [pid wstoa pay])
                  "Executes via TS02-CPAD.SNAKES|C_Acquire (the sole gas-funded path)." ]
                [ (format "Acquired {} of {} nonce {}." [amount asset nonce]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_Acquire buyer nonce amount iz-native))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_Acquire:[string]
        (buyer:string nonce:integer amount:integer iz-native:bool slippage:decimal)
        @doc "Variant 1 (with slippage) — coin.TRANSFER caps the UI signs, padded by (1 + slippage/100)."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (asset-id:string (UR_AssetID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
            )
            (ref-DEMIPAD::URC_Acquire buyer asset-id pid type slippage)
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_AcquisitionNonce (nonce:integer)
        @doc "The nonces this pad actually sells: 1 = Pure Shares, 2-8 = Tier 1-7 PackageShares. \
            \ ADDED 2026-09-14, mirroring the Custodians twin's UEV_AcquisitionNonce, which had it \
            \ from the start. Without it a nonexistent nonce was refused by the SUPPLY cap instead \
            \ -- UR_NonceSaleAvailability returns 0 for an unknown nonce, so any amount exceeds it \
            \ -- and reported \"Insufficient Assets for Acquisiton!\". That is actively misleading, \
            \ not merely terse: the implied remedy is to wait for restocking, which can NEVER work \
            \ for a nonce the pad does not sell, and the text was identical to a genuine over-buy, \
            \ so the two were indistinguishable to a client."
        (let
            (
                (acquisition-nonces:[integer] (enumerate 1 8))
                (iz-acquisition-nonce:bool (contains nonce acquisition-nonces))
            )
            (enforce iz-acquisition-nonce "Invalid Snakes Acquisition Nonce")
        )
    )
    (defun CAP_Acquire
        (buyer:string nonce:integer amount:integer iz-native:bool)
        @doc "Variant 2 (slippage off) — installs the coin.TRANSFER caps in-code at the live price."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (asset-id:string (UR_AssetID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
            )
            (ref-DEMIPAD::CAP_Acquire buyer asset-id pid type)
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_UpdateSharePrice (price:decimal)
        @doc "Updates the Share Price. \
            \ FIXED 2026-09-14 -- this was DEAD ON ARRIVAL. DEMIPAD::A_DefinePrice opens with \
            \ P|UEV_IMC, a UEV_Any over the caller-policy guards DEMIPAD has registered, and the \
            \ one that admits this module is (create-capability-guard (P|SNAKES|CALLER)). A \
            \ capability guard only passes while its capability is IN SCOPE, and this defun \
            \ acquired nothing at all -- so every invocation died on P|UEV_IMC with \
            \ \"None of the guards passed\", admin signature and all. Its sibling C_Acquire earns \
            \ the same gate because its defcap composes P|SNAKES|CALLER; this now does the same \
            \ through P|SECURE-CALLER. NOTE this grants no authority: P|SECURE-CALLER only \
            \ proves the call originates inside this module. The ACTUAL authorization is \
            \ DEMIPAD|C>DEFINE-PRICE -> DEMIPAD|C>SECURE-ADMIN -> GOV|DEMIPAD_ADMIN, which was \
            \ previously UNREACHABLE and is now the gate that decides. Pinned by \
            \ modules/LAUNCHPAD.repl."
        (with-capability (P|SECURE-CALLER)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                    (asset:string (UR_AssetID))
                )
                (ref-DEMIPAD::A_DefinePrice asset
                    {"price-per-share-in-dollars" : price}
                )
            )
        )
    )
    (defun C_Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal)
        @doc "Nonce 1 are Pure Shares, Nonces 2-8 are Tier 1-7 PackageShares \
            \ When <iz-native> is set to true, Native STOA is used for buy, which must be wrapped to WSTOA \
            \ <max-cost> is the buyer's slippage ceiling in dollars (sentinel < 0 = slippage off)."
        (with-capability (SNAKES|ACQUIRE nonce amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TS02-DPAD:module{TalosStageTwo_DemiPadV1} TS02-DPAD)
                    (ref-TS02-C1:module{TalosStageTwo_ClientOneV2} TS02-C1)
                    ;;
                    (asset:string (UR_AssetID))
                    (costs:object{DemiourgosLaunchpadV2.Costs} (URC_NonceAmountCosts nonce amount))
                    (pid:decimal (at "pid" costs))
                    (type:integer (if iz-native 0 1))
                    (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
                )
                ;;1] SOVEREIGN deposit Talos op — buyer's STOA into the Launchpad; self-collects IGNIS on patron
                (ref-TS02-DPAD::DEMIPAD|C_Deposit patron buyer asset pid type false max-cost)
                ;;2] SOVEREIGN DPDC collectable transfer Talos op — SFT nonce(s) from the Launchpad SC to the buyer; self-collects IGNIS
                (ref-TS02-C1::DPDC|C_MultiTransfer patron [asset] [true] DEMIPAD|SC_NAME buyer [[nonce]] [[amount]] true)
                (format "User {} succesfuly acquired {} Nonce {} {} SFTs" [sb amount nonce asset])
            )
        )
    )

)

;; --- tables for 02_Snakes.pact (3 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table SNAKES|T|Properties)

;; ===== 2_CITIZEN/7_Launchpad/3_Custodians/03_Custodians.pact =======
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface SaleCustodiansV2




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
    ;;
    ;;  [UC]
    ;;
    (defun UC_NonceQuintessence:integer (nonce:integer))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [UR]
    ;;
    (defun UR_AssetID ())
    (defun UR_QuitessencePrice:decimal ())
    (defun UR_NonceSaleAvailability:integer (nonce:integer))
    ;;
    ;;  [URC]
    ;;
    (defun URC_QuintessenceCosts:object{DemiourgosLaunchpadV2.Costs} ())
    (defun URC_NonceCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer))
    (defun URC_NonceAmountCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer amount:integer))
    (defun URC_Acquire:[string] (buyer:string nonce:integer amount:integer iz-native:bool slippage:decimal))
    ;;
    ;;  [URCi] / [INFO]  (pure-citizen cost preview: Sigma of the sovereign Talos ops' IGNIS)
    ;;
    (defun URCi_Acquire:decimal (buyer:string nonce:integer amount:integer iz-native:bool))
    (defun INFO_Acquire:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string nonce:integer amount:integer iz-native:bool))
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire (buyer:string nonce:integer amount:integer iz-native:bool))
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_AcquisitionNonce (nonce:integer))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A+C]
    ;;
    (defun A_UpdateQuintessencePrice (price:decimal))
    (defun C_Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal))

)
(module DEMIPAD-CUSTODIANS GOV
    @doc "Module defining the Sale Mechanics for Ouronet Custodians Collection"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SaleCustodiansV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_CUSTODIANS                         (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|CUSTODIANS_ADMIN)))
    (defcap GOV|CUSTODIANS_ADMIN ()                     (enforce-guard GOV|MD_CUSTODIANS))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|DEMIPAD|SC_NAME ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
            )
            (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME)
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
    (defcap P|CUSTODIANS|CALLER ()
        true
    )
    (defcap P|CUSTODIANS|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|CUSTODIANS|CALLER))
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
        (with-capability (GOV|CUSTODIANS_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|CUSTODIANS_ADMIN)
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
        (with-capability (GOV|CUSTODIANS_ADMIN)
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
        (with-capability (GOV|CUSTODIANS_ADMIN)
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
                (ref-P|DPDC-T:module{OuronetPolicyV2} DPDC-T)
                (ref-P|DPAD:module{OuronetPolicyV2} DEMIPAD)
                (mg:guard (create-capability-guard (P|CUSTODIANS|CALLER)))
            )
            (ref-P|DPAD::P|A_Add
                "CUSTODIANS|RemoteGov"
                (create-capability-guard (P|CUSTODIANS|REMOTE-GOV))
            )
            (ref-P|DPDC-T::P|A_AddIMP mg)
            (ref-P|DPAD::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst DEMIPAD|SC_NAME                           (GOV|DEMIPAD|SC_NAME))
    (defconst CUSTODIANS|INFO                           (CT_Info))
    (defconst BAR                                       (CT_Bar))
    ;;{3.2}  schemas
    ;;
    (defschema CUSTODIANS|PropertiesSchema
        asset-id:string
    )
    ;;{3.3}  tables
    (deftable CUSTODIANS|T|Properties:{CUSTODIANS|PropertiesSchema})

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap CUSTODIANS|C>INITIALISE ()
        @event
        (compose-capability (GOV|CUSTODIANS_ADMIN))
    )
    (defcap CUSTODIANS|ACQUIRE (nonce:integer amount:integer)
        @event
        ;;#10M: nonce validation is enforced HERE (was buried in the UR_ read, which must not enforce).
        (UEV_AcquisitionNonce nonce)
        (let
            (
                (available-supply-to-acquire:integer (UR_NonceSaleAvailability nonce))
            )
            (enforce (<= amount available-supply-to-acquire) "Insufficient Assets for Acquisiton!")
            (compose-capability (P|CUSTODIANS|CALLER))
            (compose-capability (P|CUSTODIANS|REMOTE-GOV))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Info ()                                   (at 0 ["Custodians"]))
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
    (defun UC_NonceQuintessence:integer (nonce:integer)
        @doc "Pure nonce->quintessence mapping for the three Custodian fragment nonces: \
            \ -1 (Bronze) = 1, -2 (Silver) = 10, -3 (Golden) = 100. No enforce: nonce validity \
            \ is enforced by the CUSTODIANS|ACQUIRE cap on the mutation path (UEV_AcquisitionNonce)."
        (if (= nonce -1)
            1
            (if (= nonce -2)
                10
                100
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_AssetID ()
        (at "asset-id" (read CUSTODIANS|T|Properties CUSTODIANS|INFO ["asset-id"]))
    )
    (defun UR_QuitessencePrice:decimal ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
            )
            (at "quintessence-price" (ref-DEMIPAD::UR_Price (UR_AssetID)))
        )
    )
    (defun UR_NonceSaleAvailability:integer (nonce:integer)
        ;;#10M: pure DPDC supply read (no enforce — matches the Snakes twin). Nonce validity is enforced
        ;;      by the CUSTODIANS|ACQUIRE cap on the mutation path.
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;#4H: was the non-existent GOV|LAUNCHPAD|SC_NAME → the real member (matches Snakes twin)
                (lpad:string (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME))
                (asset:string (UR_AssetID))
            )
            (ref-DPDC::UR_AccountNonceSupply lpad asset true nonce)
        )
    )
    (defun URC_QuintessenceCosts:object{DemiourgosLaunchpadV2.Costs} ()
        (let
            (
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (q-pid:decimal (UR_QuitessencePrice))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                q-pid
                (floor (/ q-pid stoa-pid) wstoa-prec)
            )
        )
    )
    (defun URC_NonceCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (q-costs:object{DemiourgosLaunchpadV2.Costs} (URC_QuintessenceCosts))
                (nonce-value-in-quintessence:integer (UC_NonceQuintessence nonce))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                (floor (* (at "pid" q-costs) (dec nonce-value-in-quintessence)) 2)
                (floor (* (at "wstoa" q-costs) (dec nonce-value-in-quintessence)) wstoa-prec)
            )
        )
    )
    (defun URC_NonceAmountCosts:object{DemiourgosLaunchpadV2.Costs} (nonce:integer amount:integer)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (nonce-costs:object{DemiourgosLaunchpadV2.Costs} (URC_NonceCosts nonce))
                ;;
                (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                (wstoa-prec:integer (ref-DPTF::UR_Decimals wstoa-id))
            )
            (ref-DEMIPAD::UDC_Costs
                (floor (* (at "pid" nonce-costs) (dec amount)) 2)
                (floor (* (at "wstoa" nonce-costs) (dec amount)) wstoa-prec)
            )
        )
    )
    (defun URCi_Acquire:decimal (buyer:string nonce:integer amount:integer iz-native:bool)
        @doc "Pure-citizen IGNIS cost preview for C_Acquire = Sigma of the two SOVEREIGN Talos ops' \
            \ IGNIS (each self-collects): DEMIPAD deposit + DPDC-T SFT nonce transfer."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (ref-DPDC-T:module{DpdcTransferV2} DPDC-T)
                (asset:string (UR_AssetID))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
                (type:integer (if iz-native 0 1))
            )
            (+ (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-DEMIPAD::URCi_Deposit buyer asset pid type false))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-DPDC-T::URCi_MultiTransferCumulator [asset] [true] DEMIPAD|SC_NAME buyer [[nonce]] [[amount]])))
               ;;MISSING LEG FIXED (2026-09-14). The Sigma counted the deposit and the transfer GAS but
               ;;not the IGNIS ROYALTY. `DPDC|C_MultiTransfer` runs `C_IgnisRoyaltyCollector patron ...`
               ;;before its own collect, and that pays the collection creator OUT OF THE PATRON — so a
               ;;buyer of a royalty-bearing nonce is charged more than this preview quoted. Measured
               ;;89.002 quoted against 89.004 charged on a 2-share buy (0.001/share).
               ;;The `(if virtual-gas-zero 0.0 ...)` mirrors the collector's own short-circuit, so the
               ;;preview stays correct when virtual gas is switched off.
               (if (ref-IGNIS::URC_IsVirtualGasZero)
                   0.0
                   (ref-DPDC-T::URC_SummedIgnisRoyalty DEMIPAD|SC_NAME asset true [nonce] [amount])))
        )
    )
    (defun INFO_Acquire:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string nonce:integer amount:integer iz-native:bool)
        @doc "Cost preview for the CUSTODIANS|C_Acquire pure-citizen buy (sole gas-funded path = the \
            \ TS02-CPAD Talos wrapper). IGNIS = URCi_Acquire (Sigma of the two Talos ops). Launchpad ops \
            \ carry NO protocol STOA fee; the ACQUISITION cost (dollar pid + STOA wstoa) is declared as \
            \ the good bought (protocol stoa = none)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (asset:string (UR_AssetID))
                (costs:object{DemiourgosLaunchpadV2.Costs} (URC_NonceAmountCosts nonce amount))
                (pid:decimal (at "pid" costs))
                (wstoa:decimal (at "wstoa" costs))
                (pay:string (if iz-native "Native STOA" "OWS (Wrapped STOA)"))
                (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Acquire {} of {} nonce {} for {} (pure-citizen, Sigma-billed)." [amount asset nonce sb])
                  (format "Acquisition cost: {} $ paid as {} {} (not a protocol fee)." [pid wstoa pay])
                  "Executes via TS02-CPAD.CUSTODIANS|C_Acquire (the sole gas-funded path)." ]
                [ (format "Acquired {} of {} nonce {}." [amount asset nonce]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_Acquire buyer nonce amount iz-native))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    (defun URC_Acquire:[string]
        (buyer:string nonce:integer amount:integer iz-native:bool slippage:decimal)
        @doc "Variant 1 (with slippage) — coin.TRANSFER caps the UI signs, padded by (1 + slippage/100)."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (asset-id:string (UR_AssetID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
            )
            (ref-DEMIPAD::URC_Acquire buyer asset-id pid type slippage)
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire
        (buyer:string nonce:integer amount:integer iz-native:bool)
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (asset-id:string (UR_AssetID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_NonceAmountCosts nonce amount)))
            )
            (ref-DEMIPAD::CAP_Acquire buyer asset-id pid type)
        )
    )
    (defun UEV_AcquisitionNonce (nonce:integer)
        (let
            (
                (acquisition-nonces:[integer] [-3 -2 -1])
                (iz-acquisition-nonce:bool (contains nonce acquisition-nonces))
            )
            (enforce iz-acquisition-nonce "Invalid Custodian Acquisition Nonce")
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 3 — Custom: GOV|CUSTODIANS_ADMIN
    (defun XI_I|AssetId (asset-id:string)
        (require-capability (GOV|CUSTODIANS_ADMIN))
        (insert CUSTODIANS|T|Properties CUSTODIANS|INFO
            {"asset-id"     : asset-id}
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_UpdateQuintessencePrice (price:decimal)
        @doc "Updates the Quintessence Price. \
            \ FIXED 2026-09-14 -- this was DEAD ON ARRIVAL. DEMIPAD::A_DefinePrice opens with \
            \ P|UEV_IMC, a UEV_Any over the caller-policy guards DEMIPAD has registered, and the \
            \ one that admits this module is (create-capability-guard (P|CUSTODIANS|CALLER)). A \
            \ capability guard only passes while its capability is IN SCOPE, and this defun \
            \ acquired nothing at all -- so every invocation died on P|UEV_IMC with \
            \ \"None of the guards passed\", admin signature and all. Its sibling C_Acquire earns \
            \ the same gate because its defcap composes P|CUSTODIANS|CALLER; this now does the same \
            \ through P|SECURE-CALLER. NOTE this grants no authority: P|SECURE-CALLER only \
            \ proves the call originates inside this module. The ACTUAL authorization is \
            \ DEMIPAD|C>DEFINE-PRICE -> DEMIPAD|C>SECURE-ADMIN -> GOV|DEMIPAD_ADMIN, which was \
            \ previously UNREACHABLE and is now the gate that decides. Pinned by \
            \ modules/LAUNCHPAD.repl."
        (with-capability (P|SECURE-CALLER)
            (let
                (
                    (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                    (asset:string (UR_AssetID))
                )
                (ref-DEMIPAD::A_DefinePrice asset
                    {"quintessence-price" : price}
                )
            )
        )
    )
    (defun C_Acquire (patron:string buyer:string nonce:integer amount:integer iz-native:bool max-cost:decimal)
        @doc "Only Nonce -3 -2 -1 can be used, and these are Bronze/Silver/Golden Fragment Nonces. \
            \ <max-cost> is the buyer's slippage ceiling in dollars (sentinel < 0 = slippage off)."
        ;;#3H: open CUSTODIANS|ACQUIRE (was missing — the twin Snakes wraps SNAKES|ACQUIRE). This restores
        ;;    the per-nonce supply cap (enforce amount <= available) + composes the P|CUSTODIANS caller
        ;;    policies the downstream DPDC-T transfer needs, and fires the @event.
        (with-capability (CUSTODIANS|ACQUIRE nonce amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TS02-DPAD:module{TalosStageTwo_DemiPadV1} TS02-DPAD)
                    (ref-TS02-C1:module{TalosStageTwo_ClientOneV2} TS02-C1)
                    ;;
                    (asset:string (UR_AssetID))
                    (costs:object{DemiourgosLaunchpadV2.Costs} (URC_NonceAmountCosts nonce amount))
                    (pid:decimal (at "pid" costs))
                    (type:integer (if iz-native 0 1))
                    (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
                )
                ;;1] SOVEREIGN deposit Talos op — buyer's STOA into the Launchpad; self-collects IGNIS on patron
                (ref-TS02-DPAD::DEMIPAD|C_Deposit patron buyer asset pid type false max-cost)
                ;;2] SOVEREIGN DPDC collectable transfer Talos op — SFT nonce(s) from the Launchpad SC to the buyer; self-collects IGNIS
                (ref-TS02-C1::DPDC|C_MultiTransfer patron [asset] [true] DEMIPAD|SC_NAME buyer [[nonce]] [[amount]] true)
                (format "User {} succesfuly acquired {} Nonce {} {} SFTs" [sb amount nonce asset])
            )
        )
    )

)

;; --- tables for 03_Custodians.pact (3 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table CUSTODIANS|T|Properties)

;; ===== 2_CITIZEN/7_Launchpad/4_StoicPay/04_STOICPAY.pact ===========
;; net: v2   ·   dev: v3   ;; bumped by the StoicSyntax refactor — deploy v3 then set net: v3
(interface StoicPayV3




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
    ;;
    ;;  [UR]
    ;;
    (defun UR_KpayID:string ())
    (defun UR_KpayLeft:decimal ())
    (defun UR_KpayPID:decimal (offset:decimal))
    (defun UR_GetPeriod:integer ())
    (defun URv_PeriodAllocation:decimal (period:integer))
    (defun UR_PAD_LEDGER_ACCOUNT:string ())
    ;;
    ;;  [URC]
    ;;
    (defun URC_KpayAmountCosts:object{DemiourgosLaunchpadV2.Costs} (amount:integer offset:decimal))
    (defun URC_Acquire:[string] (buyer:string amount:integer iz-native:bool slippage:decimal))
    (defun URC_GetMaxBuy:integer (account:string native:bool))
    ;;
    ;;  [URCi] / [INFO]  (pure-citizen cost preview: Sigma of the sovereign Talos ops' IGNIS)
    ;;
    (defun URCi_BuyStoicPay:decimal (buyer:string kpay-amount:integer iz-native:bool))
    (defun INFO_BuyStoicPay:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string kpay-amount:integer iz-native:bool))
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire (buyer:string amount:integer iz-native:bool))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_BuyStoicPay (patron:string buyer:string kpay-amount:integer iz-native:bool max-cost:decimal))

)
(module DEMIPAD-STOICPAY GOV
    @doc "StoicPay sale mechanics (DEMIPAD). UI read aggregate lives in DPL-UR as URC_0030_StoicPay."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements StoicPayV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_KPAY                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|KPAY_ADMIN)))
    (defcap GOV|KPAY_ADMIN ()                           (enforce-guard GOV|MD_KPAY))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|DEMIPAD|SC_NAME ()
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
            )
            (ref-DEMIPAD::GOV|DEMIPAD|SC_NAME)
        )
    )
    ;;Team allocation recipients (LIVE deployed set — identical to on-chain ouronet-ns.DEMIPAD-STOICPAY).
    ;;60% team share = COMPANY (30%) + VENTURE1..4 (7.5% each) = 1.5x the buyer amount per sale (40/60 split;
    ;;250M end supply). The REPL fixture creates these five accounts so the buy-side MultiBulkTransfer resolves.
    (defun GOV|COMPANY ()                               (at 0 ["Ѻ.ъΦĞρλξäFφVПÉЫÍЬÙGěЭыц¥ĄïsKзŤ8£ΞδĚãlÍŃÝþáΩĘΞȘĎĄЛδůÖîĎĄΠДÈrЪqyςkѺδKłĄρțØänÀŚxчtÍςÃΩ₳9ť7ÇяŠΛδÓdťЗΞŻÛπΩ∇цжuлiØłÛáYπOкæáYoùχmŒуŞËЛΞьPĘáÛÝaBÑБžя₳țςhrĚë₱dÑLÞЛεñeîÓУłëΦ"]))
    (defun GOV|VENTURE1 ()                              (at 0 ["Ѻ.CЭΞŸNGúůρhãmИΘÛ¢₳šШдìAÚwŚGýηЗПAÊУÔȘřŽÍζЗηmΔφDmcдΛъ₳tĂýăŮsПÞ$öœGθeBŽvąαÃfçл¢ĎĆď$şbsЦэΘNÄëÍĂνуãöž¥àZjÆůšÁœôñχŽâЩåτâн4μфAOçĎΓuЗŮnøЙãĚè6Дżîþż$цÑûρψŻïZÉλûæřΨeèÎígςeL"]))
    (defun GOV|VENTURE2 ()                              (at 0 ["Ѻ.ĄÀтмωωàŹČлďÜhÍηЛνÙνûĘõțЫåÒÛHážNÍЧψξïžŹЬΛξП¥ЮςĄEйNĄЧ9óпиÃЗ2äÔвœ₿£ČóΩÞдréě7νшDÅЬXтBørŸĂBςąЙęìvÆлμЛáΩγĘЗôåУțτжéδÚνpÍżȘĘï4ąŹȘkφNθþÀωΞÀWžIи5ь€ÊOôΣëñэÔÿνÜw1юÔzźцξńѺfś"]))
    (defun GOV|VENTURE3 ()                              (at 0 ["Ѻ.ìѺďΘčμЮÚşŁì92lźřWмPòíFùЛgßCÊȚδğďŘTπΠrπмЮ6ŁYŘэHóęÀSăλьПO€ЮrØòш2ΓεîțůOÂŁŻДÍ¥ôWxí4ïçдå₿ЙÒεЗzÝăÚÆπБцìcÕyьΘæěЖù₱фщđÝKÚßzUÉÍЬŒΠYvVŻUЫýčWŘвůćCČΦú2ãбşèуÓçË€ïmôrýмúüÄЬáó"]))
    (defun GOV|VENTURE4 ()                              (at 0 ["Ѻ.BPΩÉ5eønDMRзΣÛł4áÃÄПNΩFзÌõãBЙĞńŒμЗŽτЯÈЙÓDд5țσÆďΔÂиĂqtVŒ3ЦтòȚиåâ8юđhýZNтě∇ŹÀĂkÖѺζEğOüбĆ6мθÈSoш∇ŠmHŒДiÖĎďнÈèTuĎSжğĎЫěIťčç$ÇíżùàĐZξÁτÞFxPÎÎπÿWÖàыДŤγEψàýÔу€эjĆ2ĎżÃς"]))

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
    (defcap P|KPAY|CALLER ()
        true
    )
    (defcap P|PAD-KPAY|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|KPAY|CALLER))
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
        (with-capability (GOV|KPAY_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|KPAY_ADMIN)
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
        (with-capability (GOV|KPAY_ADMIN)
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
        (with-capability (GOV|KPAY_ADMIN)
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
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|DPAD:module{OuronetPolicyV2} DEMIPAD)
                (mg:guard (create-capability-guard (P|KPAY|CALLER)))
            )
            (ref-P|DPAD::P|A_Add
                "KPAY|RemoteGov"
                (create-capability-guard (P|PAD-KPAY|REMOTE-GOV))
            )
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|DPAD::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst DEMIPAD|SC_NAME                           (GOV|DEMIPAD|SC_NAME))
    (defconst KPAY|INFO                                 (CT_Info))
    (defconst BAR                                       (CT_Bar))
    ;;{3.2}  schemas
    ;;
    (defschema KPAY|PropertiesSchema
        asset-id:string
    )
    ;;{3.3}  tables
    (deftable KPAY|T|Properties:{KPAY|PropertiesSchema})

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap KPAY|C>BUY (kpay-amount:integer)
        @event
        (let
            (
                (KpayID:string (UR_KpayID))
                (remaining-supply:decimal (UR_KpayLeft))
                (amount:decimal (dec kpay-amount))
                (future-ten-minute-price:decimal (UR_KpayPID 600.0))
                (kpay-price:decimal
                    (if (= future-ten-minute-price -1.0)
                        (UR_KpayPID 0.0)
                        (UR_KpayPID 600.0)
                    )
                )
            )
            (enforce (<= amount remaining-supply) "Remaining Amount surpassed!")
            ;;VESTIGIAL SENTINEL. Both the -1.0 branch above and this enforce are dead, and they are
            ;;dead for the same reason: UR_KpayPID is TOTAL and strictly positive. It returns 0.01
            ;;before the sale opens, 1.0 after three years, and floor(0.01 + 0.99*elapsed/3y, 24) in
            ;;between — a value in (0.01, 1.0). It has no failure mode and never yields -1.0, so
            ;;<future-ten-minute-price> can never equal the sentinel, the `if` always takes its else
            ;;branch, and <kpay-price> is always > 0.0. "Kpay Sale has Concluded!" can never be the
            ;;reason a buyer is refused; the sale's real terminator is the supply check on the line
            ;;above. Left in place rather than deleted because removing it changes a live sale
            ;;contract for no functional gain — but it is documented here so nobody reads it as an
            ;;active gate. Backed by REPL/modules/LAUNCHPAD.repl <<TX-SPK-KPAY-PRICE>>, which pins
            ;;the price function's bounds across the whole domain instead.
            ;;UNREACHABLE
            (enforce (> kpay-price 0.0) "Kpay Sale has Concluded!")
            (compose-capability (P|PAD-KPAY|REMOTE-GOV))
            (compose-capability (P|KPAY|CALLER))
        )
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Info ()                                   (at 0 ["StoicPayV3"]))
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun UR_KpayID:string ()
        (at "asset-id" (read KPAY|T|Properties KPAY|INFO ["asset-id"]))
    )
    (defun UR_GetPeriod:integer ()
        (let
            (
                (ref-DPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (KpayID:string (UR_KpayID))
                (starting-tm:time (at "starting-time" (ref-DPAD::UR_Price KpayID)))
                (present-tm:time (at "block-time" (chain-data)))
                (three-years:decimal 94608000.0)
                (period-length:decimal (/ three-years 25.0))  ; 3,784,320 seconds
                (elapsed:decimal (diff-time present-tm starting-tm))  ; Seconds between present and start
            )
            (if (< elapsed 0.0)
                -1 ;;Before Starting Time
                (if (>= elapsed three-years)
                    0 ;;After three years
                    (if (= elapsed 0.0)
                        1
                        (let
                            (
                                (p:integer (ceiling (/ elapsed period-length)))
                            )
                            (if (> p 25)
                                25
                                p
                            )
                        )
                    )
                )
            )
        )
    )
    (defun URv_PeriodAllocation:decimal (period:integer)
        (enforce (and (>= period -1) (<= period 25)) "Invalid Period")
        (if (or (= period -1) (= period 0))
            0.0
            (let
                (
                    (a1:decimal 4.4)
                    (ak:decimal (- 4.5 (* 0.1 (dec period))))
                    (sk:decimal (* (/ (dec period) 2.0)(+ a1 ak)))
                )
                (+ 20000000 (* sk 1000000.0))
            )
        )
    )
    (defun UR_KpayLeft:decimal ()
        @doc "Computes how much KPAY can still be bought this Period"
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (KpayID:string (UR_KpayID))
                (resident-amount:decimal (ref-DPTF::UR_AccountSupply KpayID DEMIPAD|SC_NAME))
                (left-for-sale:decimal (* 0.4 resident-amount))
                (sold:decimal (- 100000000.0 left-for-sale))
                ;;
                (period:integer (UR_GetPeriod))
                (period-allocation:decimal (URv_PeriodAllocation period))
            )
            (if (or (= period -1)(= period 0))
                0.0
                (- period-allocation sold)
            )
        )
    )
    (defun UR_KpayPID:decimal (offset:decimal)
        @doc "Offset is used to compute the time with a future offset in seconds"
        (let
            (
                (ref-DPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (KpayID:string (UR_KpayID))
                (starting-tm:time (at "starting-time" (ref-DPAD::UR_Price KpayID)))
                (present-tm:time (add-time (at "block-time" (chain-data)) offset))
                (elapsed-tm:decimal (diff-time present-tm starting-tm))
                (three-years:decimal 94608000.0)
            )
            (if (<= elapsed-tm 0.0)
                0.01
                (if (> elapsed-tm three-years)
                    1.0
                    (floor (+ 0.01 (* 0.99 (/ elapsed-tm three-years))) 24)
                )
            )
        )
    )
    (defun UR_PAD_LEDGER_ACCOUNT:string ()
        @doc "Launchpad ledger account (DPTF holder) for StoicPay inventory."
        DEMIPAD|SC_NAME
    )
    (defun URC_KpayAmountCosts:object{DemiourgosLaunchpadV2.Costs} (amount:integer offset:decimal)
        @doc "Computes Prices;"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                ;;
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (KpayID:string (UR_KpayID))
                (Kpay-price:decimal (UR_KpayPID offset))
            )
            (ref-DEMIPAD::UDC_Costs
                (* (dec amount) Kpay-price)
                (floor (* (/ Kpay-price stoa-pid) (dec amount)) stoa-prec)
            )
        )
    )
    (defun URC_Acquire:[string]
        (buyer:string amount:integer iz-native:bool slippage:decimal)
        @doc "Variant 1 (with slippage) — returns the coin.TRANSFER caps the UI signs, padded by \
            \ (1 + slippage/100). An offset of 15 minutes (900.0 s) computes the values."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (KpayID:string (UR_KpayID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_KpayAmountCosts amount 900.0)))
            )
            (ref-DEMIPAD::URC_Acquire buyer KpayID pid type slippage)
        )
    )
    (defun URC_GetMaxBuy:integer (account:string native:bool)
        @doc "Returns the maximum amount of Tokens that can still be bought \
            \ Considering the amount left, and the User Funds \
            \ A price of 10 minutes in the future is used to compute price.\
            \ If there are less than 10 minutes left, the present price is used."
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)

                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-U|CT|DIA:module{DiaStoaPidV2} U|CT)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                ;;
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
                (stoa-pid:decimal (ref-U|CT|DIA::UR_STOA-PID|Price))
                ;;
                (k-account:string (ref-DALOS::UR_AccountStoa account))
                (wstoa:string (ref-DALOS::UR_WrappedStoaID))
                (KpayID:string (UR_KpayID))
                (future-ten-minute-price:decimal (UR_KpayPID 600.0))
                (present-price:decimal (UR_KpayPID 0.0))
                (kpay-price:decimal
                    (if (= present-price future-ten-minute-price)
                        present-price
                        future-ten-minute-price
                    )
                )
                (still-for-sale:integer (floor (UR_KpayLeft)))
                ;;
                (client-stoa-supply:decimal
                    (if native
                        (ref-coin::get-balance k-account)
                        (ref-DPTF::UR_AccountSupply wstoa account)
                    )
                )
                (client-stoa-value-in-dollarz:decimal (floor (* client-stoa-supply stoa-pid) 2))
                (can-buy-with-client-supply:integer 
                    (if (= kpay-price -1.0)
                        0
                        (floor (/ client-stoa-value-in-dollarz kpay-price))
                    )
                )
                (period:integer (UR_GetPeriod))
            )
            (if (or (= period -1) (= period 0))
                0
                (if (<= can-buy-with-client-supply still-for-sale)
                    can-buy-with-client-supply
                    still-for-sale
                )
            )
        )
    )
    (defun URCi_BuyStoicPay:decimal (buyer:string kpay-amount:integer iz-native:bool)
        @doc "Pure-citizen IGNIS cost preview for C_BuyStoicPay = Sigma of the three SOVEREIGN Talos \
            \ ops' IGNIS (each self-collects): DEMIPAD deposit + DPTF StoicPay-out transfer + DPTF \
            \ multi-bulk venture-split transfer."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (KpayID:string (UR_KpayID))
                (pid:decimal (at "pid" (URC_KpayAmountCosts kpay-amount 0.0)))
                (type:integer (if iz-native 0 1))
                (ten-p:decimal (* 0.25 (dec kpay-amount)))
                (twenty-p:decimal (* 0.5 (dec kpay-amount)))
            )
            (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                   (ref-DEMIPAD::URCi_Deposit buyer KpayID pid type false))
               (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-TFT::URCi_Transfer KpayID DEMIPAD|SC_NAME buyer (dec kpay-amount)))
                  (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                      (ref-TFT::URCi_MultiBulkTransferCumulator [KpayID] DEMIPAD|SC_NAME
                          [[(GOV|COMPANY) (GOV|VENTURE1) (GOV|VENTURE2) (GOV|VENTURE3) (GOV|VENTURE4)]]
                          [[twenty-p ten-p ten-p ten-p ten-p]]))))
        )
    )
    (defun INFO_BuyStoicPay:object{OuronetInfoV2.ClientInfo} (patron:string buyer:string kpay-amount:integer iz-native:bool)
        @doc "Cost preview for the KPAY|C_BuyStoicPay pure-citizen buy (sole gas-funded path = the \
            \ TS02-CPAD Talos wrapper). IGNIS = URCi_BuyStoicPay (Sigma of the three Talos ops). \
            \ Launchpad ops carry NO protocol STOA fee; the ACQUISITION cost (dollar pid + STOA wstoa) \
            \ is declared as the good bought (protocol stoa = none)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (KpayID:string (UR_KpayID))
                (costs:object{DemiourgosLaunchpadV2.Costs} (URC_KpayAmountCosts kpay-amount 0.0))
                (pid:decimal (at "pid" costs))
                (wstoa:decimal (at "wstoa" costs))
                (pay:string (if iz-native "Native STOA" "OWS (Wrapped STOA)"))
                (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Buy {} {} StoicPay for {} (pure-citizen, Sigma-billed)." [kpay-amount KpayID sb])
                  (format "Acquisition cost: {} $ paid as {} {} (not a protocol fee)." [pid wstoa pay])
                  "Executes via TS02-CPAD.KPAY|C_BuyStoicPay (the sole gas-funded path)." ]
                [ (format "Acquired {} {} StoicPay." [kpay-amount KpayID]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_BuyStoicPay buyer kpay-amount iz-native))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun CAP_Acquire
        (buyer:string amount:integer iz-native:bool)
        @doc "Variant 2 (slippage off) — installs the coin.TRANSFER caps in-code at the live price; the \
            \ UI does NOT sign them and warns the buyer the mined price may differ."
        (let
            (
                (ref-DEMIPAD:module{DemiourgosLaunchpadV2} DEMIPAD)
                (KpayID:string (UR_KpayID))
                (type:integer (if iz-native 0 1))
                (pid:decimal (at "pid" (URC_KpayAmountCosts amount 900.0)))
            )
            (ref-DEMIPAD::CAP_Acquire buyer KpayID pid type)
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun C_BuyStoicPay (patron:string buyer:string kpay-amount:integer iz-native:bool max-cost:decimal)
        @doc "<max-cost> is the buyer's slippage ceiling in dollars (Variant 1); pass a sentinel below \
            \ zero for the slippage-off path (Variant 2)."
        (with-capability (KPAY|C>BUY kpay-amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TS02-DPAD:module{TalosStageTwo_DemiPadV1} TS02-DPAD)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    ;;
                    (KpayID:string (UR_KpayID))
                    (costs:object{DemiourgosLaunchpadV2.Costs} (URC_KpayAmountCosts kpay-amount 0.0))
                    (pid:decimal (at "pid" costs))
                    (type:integer (if iz-native 0 1))
                    (ten-p:decimal (* 0.25 (dec kpay-amount)))
                    (twenty-p:decimal (* 0.5 (dec kpay-amount)))
                    (sb:string (ref-I|OURONET::OI|UC_ShortAccount buyer))
                    (present-kpay-price:decimal (UR_KpayPID 0.0))
                    (paid:decimal (at "wstoa" costs))
                )
                ;;1] SOVEREIGN deposit Talos op — buyer's STOA into the Launchpad; self-collects IGNIS on patron
                (ref-TS02-DPAD::DEMIPAD|C_Deposit patron buyer KpayID pid type false max-cost)
                ;;2] SOVEREIGN DPTF transfer Talos op — StoicPay from the Launchpad SC to the buyer; self-collects IGNIS
                (ref-TS01-C1::DPTF|C_Transfer patron KpayID DEMIPAD|SC_NAME buyer (dec kpay-amount) true)
                ;;3] SOVEREIGN DPTF multi-bulk transfer Talos op — venture split (company 50% + 4 ventures); self-collects IGNIS
                (ref-TS01-C1::DPTF|C_MultiBulkTransfer patron [KpayID] DEMIPAD|SC_NAME
                    [[(GOV|COMPANY) (GOV|VENTURE1) (GOV|VENTURE2) (GOV|VENTURE3) (GOV|VENTURE4)]]
                    [[twenty-p ten-p ten-p ten-p ten-p]])
                (if iz-native
                    (format "Account {} succesfully acquired {} STOICPAY at {} $ per Unit with {} Native STOA"
                        [sb kpay-amount present-kpay-price paid]
                    )
                    (format "Account {} succesfully acquired {} STOICPAY at {} $ per Unit with {} OWS"
                        [sb kpay-amount present-kpay-price paid]
                    )
                )
            )
        )
    )

)

;; --- tables for 04_STOICPAY.pact (3 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table KPAY|T|Properties)

;; ===== 2_CITIZEN/7_Launchpad/5_StoicIco/05_STOAICO.pact ============
(module STOAICO GOV






    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_STOAICO                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|STOAICO_ADMIN)))
    (defcap GOV|STOAICO_ADMIN ()                        (enforce-guard GOV|MD_STOAICO))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|LaunchpadKey ()                          (+ (CT_Namespace) ".dh_sc_mb-keyset"))
    ;;
    ;; [SC-Names]
    (defun GOV|DEMIPAD|SC_NAME ()                       (at 0 ["Σ.Îäć$ЬчýφVεÎÿůпΨÖůηüηŞйnюŽXΣşpЩß5ςĂκ£RäbE₳èËłŹŘYшÆgлoюýRαѺÑÏρζt∇ŹÏýжIŒațэVÞÛщŹЭδźvëȘĂтPЖÃÇЭiërđÈÝДÖšжzČđзUĚĂsкιnãñOÔIKпŞΛI₳zÄû$ρśθ6ΨЬпYпĞHöÝйÏюşí2ćщÞΔΔŻTж€₿ŞhTțŽ"]))
    ;;
    ;; [PBLs]
    (defun GOV|DEMIPAD|PBL ()                           (at 0 ["9F.gGCkuc2wMAnFAjuFphikftLdl6qFqBD4yfeMEe9u65yMqf4r340Jd6dphh1d7E1cE20btMwl4HJ2cBEMvp209GA1eD4syB96hu4nmpFbB7dKnJEMz4p8fGLcmhvrBCfDmM0axnGin8qedl5vDtwbgL3l1aK5BsmjkEEJartqCH8qG8ialtjxwCcIMf50t2lkeww6Dct5LlmmLG25FmfpcgnwMMnkJl4Gfn9gwoA6vm0jKebjhodeJLjxnh9L11ss8f26866dqv1tEphxFFqutGetH4Itj3rHkrcrGsnlqpf4gfJp94b0gBwIBe4vCj6ha8jm6kd3f8B6pEaJtkJ3fbs6rCcGibltz1BAMn0vvKME5ddFyGBnzssk1s2s0vFzwxs6vjC61Ma2l1xDxqdg1thAk2u01hDiGndLhzK73HAfgtk7bxscn0qKhymG6JAqnEFt282pyHAq5nIthK9bA8nH76x7FEpLz4eK9tLIBsyjb8M5DxaeEei6pEnLxFCAg7ulacgtjjpjMiAaqhpmM1jEHqjt4G85q4L33zrME7whgIkIpIgwnF2qKd4"]))

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
    (defcap P|STOAICO|CALLER ()
        true
    )
    (defcap P|PAD-STOAICO|REMOTE-GOV ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|STOAICO|CALLER))
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
        (with-capability (GOV|STOAICO_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|STOAICO_ADMIN)
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
        (with-capability (GOV|STOAICO_ADMIN)
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
        (with-capability (GOV|STOAICO_ADMIN)
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
                (ref-P|DPAD:module{OuronetPolicyV2} DEMIPAD)
                (mg:guard (create-capability-guard (P|STOAICO|CALLER)))
            )
            (ref-P|DPAD::P|A_Add
                "STOAICO|RemoteGov"
                (create-capability-guard (P|PAD-STOAICO|REMOTE-GOV))
            )
            (ref-P|DPAD::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst DEMIPAD|SC_NAME                           (GOV|DEMIPAD|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst STOAICO|INFO                              (CT_Info))
    (defconst STOA_PREC                                 12)
    ;;{3.2}  schemas
    ;;
    (defschema UserContributionSchema
        dollarz:decimal             ;;Adds dollars contributed
        urstoa-earned:integer       ;;Adds Urstoa earned (WURSTOA bought with 5$ Contributions)
        ;;
        ;;Distribution-Vault-Data
        ;;v-dollarz                 ;;Stores the amount of Dollarz Contributed by Account; same as <dollarz>
        last-rps:decimal            ;;Value of the Users last RPS
        pending-rewards:decimal     ;;Amount of pending rewards the user can claim (amount of WSTOA user can still claim)
        last-collected-round:integer ;;#1C: the distribution-round this account last collected. Collect allowed only when < the vault distribution-round (one collect per round; a new A_Inject opens the next round).
        ;;
        ;;Select Keyz
        owner-id:string             ;;Ouronet Account
    )
    (defschema GeneralContributionSchema
        dollarz:decimal             ;;Adds dollars contributed
        urstoa-left:integer         ;;Subtracts, storing UrStoa left
        users:integer               ;;Stores number of participants
        ;;
        ;;Distribution-Vault-Data
        ;;v-dollarz-supply          ;;Stores the total amount of Virtual Dollars in the Vault; same as <dollarz>; Functions as global score
        wstoa-supply:decimal        ;;Stores the total WSTOA held by the distribution Vault (10 mil wSTOA of ICO sale)
        nzs-count:integer           ;;Stores the number of users with non zero score.
        current-rps:decimal         ;;Stores current RPS decimal
        unclaimed-count:integer     ;;Stores the total number of user with unclaimed Rewards.
        distribution-round:integer  ;;#1C: monotonic distribution-round counter, ++ on every A_Inject. Gates collect eligibility (per-round idempotency) and the inject barrier (a new round opens only when unclaimed-count == 0).
        zombie-rewards:decimal      ;;#5M: escrow-on-empty (mirrors AQP). wSTOA injected while vault-score==0 (no stakers) is parked here (not divided) and flushed by the next non-zero-score inject (eff = amount + zombie).
        ;;
        ;;IDs
        wstoa:string
        wurstoa:string
        vusd:string
    )
    ;;{3.3}  tables
    (deftable STOAICO|T|User:{UserContributionSchema})          ;;Key = <Ouronet-Account>
    (deftable STOAICO|T|General:{GeneralContributionSchema})    ;;Key = <STOAICO|INFO>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap INIT-ICO-DISTRIBUTION ()
        @event
        (compose-capability (SECURE))
        (compose-capability (GOV))
    )
    (defcap STOAICO|INJECT (account:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (compose-capability (STOAICO|ADMIN))
        )
    )
    (defcap STOAICO|ADD-CONTRIBUTION (account:string v-usd-amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (v-usd-id:string (UR_Global10))
            )
            (ref-DALOS::UEV_EnforceAccountExists account)
            (ref-DPTF::UEV_Amount v-usd-id v-usd-amount)
            (compose-capability (STOAICO|ADMIN))
        )
    )
    (defcap STOAICO|REMOVE-CONTRIBUTION (account:string v-usd-amount:decimal)
        @event
        (compose-capability (STOAICO|ADMIN))
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (v-usd-id:string (UR_Global10))
                (user-score:decimal (UR_User1 account))
            )
            (ref-DPTF::UEV_Amount v-usd-id v-usd-amount)
            (enforce 
                (<= v-usd-amount user-score) 
                (format "Removing {} from Account {} exceeds its existing balance" [v-usd-amount account])
            )
        )
    )
    (defcap STOAICO|REDEEM-CONTRIBUTION (account:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (iz-account:bool (UR_IzAccount account))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (enforce iz-account (format "Account {} cannot be redeemed" [account]))
            ;;#1C: per-round idempotency — an account may collect at most once per distribution-round.
            ;;     This is the guard that kills the drain (the unclaimed-count can no longer be walked
            ;;     down to the whole-supply dust-sweep by repeated zero-value re-collects).
            (enforce
                (< (UR_User5 account) (UR_Global11))
                (format "Account {} has already collected this distribution round" [account]))
            (compose-capability (SECURE))
            (compose-capability (P|PAD-STOAICO|REMOTE-GOV))
        )
    )
    (defcap STOAICO|ADMIN ()
        (compose-capability (GOV))
        (compose-capability (SECURE))
        (compose-capability (P|PAD-STOAICO|REMOTE-GOV))
    )
    (defcap STOAICO|FLUSH ()
        @doc "#1C admin flush authorization — push-collect uncollected stragglers on their behalf (delivered \
            \ to them). Composes STOAICO|ADMIN, so XI_CollectFor runs in the same SECURE + REMOTE-GOV context \
            \ as a self-collect, plus admin. Evented."
        @event
        (compose-capability (STOAICO|ADMIN))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    ;;
    ;; [Keys]
    (defun CT_Namespace ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    (defun CT_Info ()                                   (at 0 ["StoaIcoInformation"]))
    ;;
    (defun UDC_UserData:object{UserContributionSchema}
        (a:decimal b:integer c:decimal d:decimal f:integer e:string)
        {"dollarz"              : a
        ,"urstoa-earned"        : b
        ,"last-rps"             : c
        ,"pending-rewards"      : d
        ,"last-collected-round" : f
        ,"owner-id"             : e}
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_User0:object{UserContributionSchema} (account:string)
        (let
            (
                (current-rps:decimal (UR_Global6))
            )
            (with-default-read STOAICO|T|User account
                (UDC_UserData 0.0 0 current-rps 0.0 0 account)
                {"dollarz":= d, "urstoa-earned" := ue, "last-rps" := lrps, "pending-rewards" := pr, "last-collected-round" := lcr, "owner-id" := id}
                (UDC_UserData d ue lrps pr lcr id)
            )
        )   
    )
    (defun UR_User1:decimal (account:string)
        (with-default-read STOAICO|T|User account
            {"dollarz" : 0.0}
            {"dollarz" := d}
            d
        )
    )
    (defun UR_User2:integer (account:string)
        (with-default-read STOAICO|T|User account
            {"urstoa-earned" : 0}
            {"urstoa-earned" := ue}
            ue
        )
    )
    (defun UR_User3:decimal (account:string)
        (let
            (
                (current-rps:decimal (UR_Global6))
            )
            (with-default-read STOAICO|T|User account
                {"last-rps" : current-rps}
                {"last-rps" := l-rps}
                l-rps
            )
        )
    )
    (defun UR_User4:decimal (account:string)
        (with-default-read STOAICO|T|User account
            {"pending-rewards" : 0.0}
            {"pending-rewards" := pr}
            pr
        )
    )
    (defun UR_User5:integer (account:string)
        @doc "#1C: the distribution-round this account last collected (0 default)."
        (with-default-read STOAICO|T|User account
            {"last-collected-round" : 0}
            {"last-collected-round" := lcr}
            lcr
        )
    )
    ;;
    (defun UR_Global0:object{GeneralContributionSchema} ()
        (read STOAICO|T|General STOAICO|INFO)
    )
    (defun UR_Global1:decimal ()
        (at "dollarz" (read STOAICO|T|General STOAICO|INFO ["dollarz"]))
    )
    (defun UR_Global2:integer ()
        (at "urstoa-left" (read STOAICO|T|General STOAICO|INFO ["urstoa-left"]))
    )
    (defun UR_Global3:integer ()
        (at "users" (read STOAICO|T|General STOAICO|INFO ["users"]))
    )
    (defun UR_Global4:decimal ()
        (at "wstoa-supply" (read STOAICO|T|General STOAICO|INFO ["wstoa-supply"]))
    )
    (defun UR_Global5:integer ()
        (at "nzs-count" (read STOAICO|T|General STOAICO|INFO ["nzs-count"]))
    )
    (defun UR_Global6:decimal ()
        (at "current-rps" (read STOAICO|T|General STOAICO|INFO ["current-rps"]))
    )
    (defun UR_Global7:integer ()
        (at "unclaimed-count" (read STOAICO|T|General STOAICO|INFO ["unclaimed-count"]))
    )
    (defun UR_Global8:string ()
        (at "wstoa" (read STOAICO|T|General STOAICO|INFO ["wstoa"]))
    )
    (defun UR_Global9:string ()
        (at "wurstoa" (read STOAICO|T|General STOAICO|INFO ["wurstoa"]))
    )
    (defun UR_Global10:string ()
        (at "vusd" (read STOAICO|T|General STOAICO|INFO ["vusd"]))
    )
    (defun UR_Global11:integer ()
        @doc "#1C: the vault distribution-round (monotonic, ++ on every A_Inject)."
        (at "distribution-round" (read STOAICO|T|General STOAICO|INFO ["distribution-round"]))
    )
    (defun UR_Global12:decimal ()
        @doc "#5M: escrowed zombie-rewards — wSTOA injected while the vault had no stakers, awaiting the next non-zero-score inject."
        (at "zombie-rewards" (read STOAICO|T|General STOAICO|INFO ["zombie-rewards"]))
    )
    ;;
    (defun UR_IzAccount:bool (account:string)
        @doc "Checks if an account exists"
        (let
            (
                (trial (try false (read STOAICO|T|User account)))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun URC_IzDustSweepClaimant:bool (account:string)
        @doc "Is ACCOUNT the one remaining unclaimed claimant, and therefore the one the dust \
            \ sweep should pay the whole vault to? Three conditions, all O(1): exactly one \
            \ unclaimed position remains; this account is a real staker; and this account has \
            \ not already collected in the current distribution-round. \
            \ ADDED 2026-09-14. URC_ClaimableRewards used to test only the FIRST of the three, \
            \ so it answered a question about the VAULT and used it as an answer about the \
            \ ACCOUNT -- see the comment there."
        (fold (and) true
            [
                (= (UR_Global7) 1)
                (> (UR_User1 account) 0.0)
                (< (UR_User5 account) (UR_Global11))
            ]
        )
    )
    (defun URC_ClaimableRewards (account:string)
        @doc "Computes Claimable Reward of Account. When exactly one unclaimed position remains, \
            \ that claimant is paid the WHOLE remaining vault -- a dust sweep, so rounding \
            \ residue is never stranded."
        ;;DEFECT FIXED 2026-09-14 (red team RT-E-001). This read:
        ;;
        ;;    (if (= (UR_Global7) 1) (UR_Global4) (URC_AvailableRewards account))
        ;;
        ;;<UR_Global7> is unclaimed-count -- a property of the VAULT. The branch asked "is exactly
        ;;one claimant left?" and never "is THIS account that claimant?", so it offered the entire
        ;;vault to ANY caller whenever the count happened to be 1. The guard tested a global and
        ;;returned a per-account figure.
        ;;
        ;;It was reachable by a LEGITIMATE admin action, not an attack: unclaimed-count is set to
        ;;nzs-count only at inject, so recording a late contribution moves nzs-count and leaves
        ;;unclaimed-count behind. Measured at RedTeam/[RT-E]_Sequencing.repl <<RT-E-001>> --
        ;;counters diverged to 1 vs 3, and an account owed 0.000000000000 was offered
        ;;690.525983513596.
        ;;
        ;;NO THEFT WAS POSSIBLE, and the reason is worth keeping: A_Stake stamps a new contributor's
        ;;<last-collected-round> to the CURRENT round, and the collect capability enforces
        ;;(< last-collected-round distribution-round) -- a newcomer is born already-collected for
        ;;the round they joined. So the money never moved. But this reader also feeds URCi_Collect
        ;;and INFO_Collect, which told such an account it would receive the whole vault; and the
        ;;theft was prevented by a stamp written in a DIFFERENT function, with nothing connecting
        ;;the two. A number that is wrong everywhere except where one unrelated guard happens to
        ;;stop it is a defect, not a defence.
        (if (URC_IzDustSweepClaimant account)
            (UR_Global4)
            (URC_AvailableRewards account)
        )
    )
    (defun URC_AvailableRewards (account:string)
        (let
            (
                (current-pending-rewards:decimal (UR_User4 account))
                (current-score:decimal (UR_User1 account))
                (last-rps:decimal (UR_User3 account))
                (current-rps:decimal (UR_Global6))
                ;;
                (diff-rps:decimal (- current-rps last-rps))
                (gained-pending-rewards:decimal (floor (* current-score diff-rps) STOA_PREC))
            )
            (+ current-pending-rewards gained-pending-rewards)
        )
    )
    (defun URH_UncollectedAccounts:[string] ()
        @doc "#1C Hydra preflight — the ONE heavy read: every account that still holds an UNCOLLECTED \
            \ position this distribution-round, i.e. an actual staker (dollarz > 0) whose \
            \ last-collected-round is behind the vault distribution-round. The UI slices this list into \
            \ capacity-bounded Ap_FlushUncollectedSlice legs; AA_FlushUncollected consumes it whole."
        (let
            (
                (cur-round:integer (UR_Global11))
            )
            (map
                (lambda (row:object{UserContributionSchema}) (at "owner-id" row))
                (select STOAICO|T|User
                    (and?
                        (where "last-collected-round" (> cur-round))
                        (where "dollarz" (< 0.0))
                    )
                )
            )
        )
    )
    (defun URCi_Collect:decimal (account:string)
        @doc "Pure-citizen IGNIS cost preview for C_Collect = Sigma of the sovereign Talos ops XI_CollectFor \
            \ fires: DPTF remint of urSTOA + the reward payout — a MultiTransfer (wSTOA+urSTOA) when urSTOA \
            \ is non-zero, else a single wSTOA Transfer. Data-dependent, dirty-read-fed from the live vault."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (wSTOA-supply:decimal (URC_ClaimableRewards account))
                (urSTOA-supply:decimal (dec (UR_User2 account)))
                (wSTOA-id:string (UR_Global8))
                (urSTOA-id:string (UR_Global9))
            )
            ;;PREVIEW/EXEC PARITY FIX (2026-09-17). The mint leg used to sit OUTSIDE this `if`,
            ;;added unconditionally — exactly where `XI_CollectFor`'s mint used to sit before the
            ;;2026-09-14 vault-deadlock fix moved it INSIDE the `(!= urSTOA-supply 0.0)` guard.
            ;;That fix repaired the EXECUTOR and left this READER alone, so the two disagreed on
            ;;every collect after an account's first — and the first collect is what zeroes urSTOA,
            ;;which makes the disagreeing case the NORMAL one, not an edge.
            ;;
            ;;Measured before the fix: preview 88.0 (mint 87.0 + transfer 1.0) for an operation
            ;;that charged 1.0. An 88x overstatement in the number a client is shown BEFORE
            ;;committing. Pinned by REPL/RedTeam/[RT-K]_PreviewParity.repl <<RT-K-008>>.
            (if (!= urSTOA-supply 0.0)
                (+ (ref-I|OURONET::OI|UC_IfpFromOutputCumulator (ref-DPTF::URCi_Mint urSTOA-id DEMIPAD|SC_NAME false))
                   (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                       (ref-TFT::URCi_MultiTransferCumulator [wSTOA-id urSTOA-id] DEMIPAD|SC_NAME account [wSTOA-supply urSTOA-supply])))
                (ref-I|OURONET::OI|UC_IfpFromOutputCumulator
                    (ref-TFT::URCi_Transfer wSTOA-id DEMIPAD|SC_NAME account wSTOA-supply)))
        )
    )
    (defun INFO_Collect:object{OuronetInfoV2.ClientInfo} (patron:string account:string)
        @doc "Cost preview for the STOAICO|C_Collect pure-citizen reward collect (sole gas-funded path = \
            \ the TS02-CPAD Talos wrapper). IGNIS = URCi_Collect. No protocol STOA fee; the collect DELIVERS \
            \ wSTOA + urSTOA rewards to the account (a payout, not a cost)."
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (wSTOA-supply:decimal (URC_ClaimableRewards account))
                (urSTOA-supply:decimal (dec (UR_User2 account)))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            (ref-I|OURONET::OI|UDC_ClientInfo
                [ (format "Operation: Collect distribution rewards for {} (pure-citizen, Sigma-billed)." [sa])
                  (format "Delivers {} wSTOA + {} urSTOA to the account (a payout, not a cost)." [wSTOA-supply urSTOA-supply]) ]
                [ (format "Collected {} wSTOA + {} urSTOA." [wSTOA-supply urSTOA-supply]) ]
                (ref-I|OURONET::OI|UDC_DynamicIgnisCost patron (URCi_Collect account))
                (ref-I|OURONET::OI|UDC_NoStoaCosts)
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 2 — SECURE
    (defun XI_CollectFor:string (patron:string account:string)
        @doc "#1C shared settle+deliver core: pays <account> its OWN wSTOA (its RPS delta, or the whole \
            \ remaining wstoa-supply when it is the round's last unclaimed staker — the dust sweep) plus its \
            \ urSTOA, then stamps it collected for the current distribution-round and decrements \
            \ unclaimed-count. Used by C_Collect (self-collect, gated by STOAICO|REDEEM-CONTRIBUTION) and by \
            \ the admin flush (push-collect on behalf of a straggler, gated by STOAICO|FLUSH). SECURE."
        (require-capability (SECURE))
        (let
            (
                (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                (wSTOA-supply:decimal (URC_ClaimableRewards account))
                (urSTOA-supply:decimal (dec (UR_User2 account)))
                (wSTOA-id:string (UR_Global8))
                (urSTOA-id:string (UR_Global9))
                (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
            )
            ;;1]Collect wSTOA and URSTOA Rewards — delivered to <account>, the rightful owner
            ;;
            ;;VAULT-DEADLOCK FIX (2026-09-14). The urSTOA mint used to sit ABOVE this `if`,
            ;;UNCONDITIONAL, while only the DELIVERY was guarded on (!= urSTOA-supply 0.0). But a
            ;;zero-amount mint is refused: C_Mint -> DPTF|C>MINT -> DPTF|C>CREDIT -> UEV_Amount ->
            ;;(enforce (> amount 0.0)). And step 6 below (XI_ResetUrstoaEarned) zeroes the account's
            ;;urSTOA entitlement as part of its FIRST collect. So on the account's SECOND
            ;;distribution-round -- when a fresh A_Inject has advanced <current-rps> and real wSTOA
            ;;IS owed -- the whole transaction aborted on the mint.
            ;;
            ;;It was a DEADLOCK, not a nuisance, because all three exits share this core and shut
            ;;together: C_Collect aborts; AA_FlushUncollected maps XI_CollectFor over the stragglers
            ;;and fails identically; and A_Inject refuses to open a new round while
            ;;(!= unclaimed-count 0). The vault stops paying and cannot be restarted from ANY
            ;;entrypoint. IGNIS::XB_MoveDalosFuel documents this exact lesson in its own @doc --
            ;;it simply was not applied here.
            ;;
            ;;The fix is the guard the delivery already had, moved to cover the mint as well. The
            ;;wSTOA leg is guarded on the same principle: a staker whose RPS delta is zero has
            ;;nothing to transfer either, and a zero transfer is refused by the same UEV_Amount.
            ;;Steps 2-6 still run in every branch, which is what actually clears the straggler out
            ;;of <unclaimed-count> and lets the next round open.
            (if (!= urSTOA-supply 0.0)
                (do
                    (ref-TS01-C1::DPTF|C_Mint patron urSTOA-id DEMIPAD|SC_NAME urSTOA-supply false)
                    (if (!= wSTOA-supply 0.0)
                        (ref-TS01-C1::DPTF|C_MultiTransfer patron
                            [wSTOA-id urSTOA-id] DEMIPAD|SC_NAME account
                            [wSTOA-supply urSTOA-supply] true
                        )
                        (ref-TS01-C1::DPTF|C_Transfer patron urSTOA-id DEMIPAD|SC_NAME account urSTOA-supply true)
                    )
                )
                (if (!= wSTOA-supply 0.0)
                    (ref-TS01-C1::DPTF|C_Transfer patron wSTOA-id DEMIPAD|SC_NAME account wSTOA-supply true)
                    "STOAICO: nothing owed this round -- settle-only, no delivery"
                )
            )
            ;;2]Reset <pending-rewards> to 0
            (XI_ResetPendingRewards account)
            ;;3]Decrement <unclaimed-count>
            (XI_UpdateUnclaimedCount false)
            ;;4]Update <last-rps> with the D-Vault <current-rps>
            (XI_UpdateUserRPS account (UR_Global6))
            ;;5]Update Vault Supply
            (XI_UpdateVaultSupply wSTOA-supply false)
            (XI_ResetUrstoaEarned account)
            ;;6]#1C: stamp this account as collected for the current distribution-round
            (XI_MarkCollected account)
            ;;7]Return claimed amounts
            (if (!= urSTOA-supply 0.0)
                (format
                    "Account {} succesfully claimed {} {} and {} {}"
                    [sa wSTOA-supply wSTOA-id urSTOA-supply urSTOA-id]
                )
                (format
                    "Account {} succesfully claimed {} {} and no {}"
                    [sa wSTOA-supply wSTOA-id urSTOA-id]
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_ResetPendingRewards (account:string)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"pending-rewards" : 0.0}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateUnclaimedCount (direction:bool)
        (require-capability (SECURE))
        (let
            (
                (uc:integer (UR_Global7))
                (new-uc:integer
                    (if direction
                        (+ uc 1)
                        (- uc 1)
                    )
                )
            )
            (update STOAICO|T|General STOAICO|INFO
                {"unclaimed-count" : new-uc}
            )
        )
    )
    ;;Admin
    ;;Protection: Class 2 — SECURE
    (defun XI_InitialiseDistributionVault (dptf-ids:[string])
        (require-capability (SECURE))
        (insert STOAICO|T|General STOAICO|INFO
            {"dollarz"          : 0.0
            ,"urstoa-left"      : 250000
            ,"users"            : 0
            ,"wstoa-supply"     : 0.0
            ,"nzs-count"        : 0
            ,"current-rps"      : 0.0
            ,"unclaimed-count"  : 0
            ,"distribution-round" : 0
            ,"zombie-rewards"   : 0.0
            ,"wstoa"            : (at 0 dptf-ids)
            ,"wurstoa"          : (at 1 dptf-ids)
            ,"vusd"             : (at 2 dptf-ids)
            }
        )
    )
    ;;User
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateUserScore (account:string amount:decimal direction:bool)
        (require-capability (SECURE))
        (let
            (
                (user-score:decimal (UR_User1 account))
                (new-user-score:decimal
                    (if direction
                        (+ user-score amount)
                        (- user-score amount)
                    )
                )
            )
            (update STOAICO|T|User account
                {"dollarz" : new-user-score}
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateUserRPS (account:string new-rps:decimal)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"last-rps" : new-rps}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_MarkCollected (account:string)
        @doc "#1C: stamp the account as having collected the CURRENT distribution-round."
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"last-collected-round" : (UR_Global11)}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdatePendingRewards (account:string)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"pending-rewards" : (URC_AvailableRewards account)}
        )
    )
    ;;D-Vault
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVaultScore (amount:decimal direction:bool)
        (require-capability (SECURE))
        (let
            (
                (vault-score:decimal (UR_Global1))
                (new-vault-score:decimal
                    (if direction
                        (+ vault-score amount)
                        (- vault-score amount)
                    )
                )
            )
            (update STOAICO|T|General STOAICO|INFO
                {"dollarz" : new-vault-score}
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVaultSupply (amount:decimal direction:bool)
        (require-capability (SECURE))
        (let
            (
                (vault-supply:decimal (UR_Global4))
                (new-vault-supply:decimal
                    (if direction
                        (+ vault-supply amount)
                        (- vault-supply amount)
                    )
                )
            )
            (update STOAICO|T|General STOAICO|INFO
                {"wstoa-supply" : new-vault-supply}
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateNZS (direction:bool)
        (require-capability (SECURE))
        (let
            (
                (nzs:integer (UR_Global5))
                (new-nzs:integer
                    (if direction
                        (+ nzs 1)
                        (- nzs 1)
                    )
                )
            )
            (update STOAICO|T|General STOAICO|INFO
                {"nzs-count" : new-nzs}
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateVaultRPS (new-rps:decimal)
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"current-rps" : new-rps}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_ResetUnclaimedCount ()
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"unclaimed-count" : (UR_Global5)}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_IncrementDistributionRound ()
        @doc "#1C: advance the vault to the next distribution-round (called by A_Inject)."
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"distribution-round" : (+ 1 (UR_Global11))}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_SetZombieRewards (amount:decimal)
        @doc "#5M: set the escrowed zombie-rewards (escrow adds to it; a flush zeroes it)."
        (require-capability (SECURE))
        (update STOAICO|T|General STOAICO|INFO
            {"zombie-rewards" : amount}
        )
    )
    ;;
    ;;Protection: Class 2 — SECURE
    (defun XI_ResetUrstoaEarned (account:string)
        (require-capability (SECURE))
        (update STOAICO|T|User account
            {"urstoa-earned"    : 0}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateUrstoaEarned (account:string v-usd-amount:decimal direction:bool)
        (require-capability (SECURE))
        (let
            (
                (user-score:decimal (UR_User1 account))
                (new-user-score:decimal
                    (if direction
                        (+ user-score v-usd-amount)
                        (- user-score v-usd-amount)
                    )
                )
                (vault-score:decimal (UR_Global1))
                (new-vault-score:decimal
                    (if direction
                        (+ vault-score v-usd-amount)
                        (- vault-score v-usd-amount)
                    )
                )
                (urstoa-left:integer (UR_Global2))
                (present-urstoa-earned:integer (UR_User2 account))
                (new-urstoa-earned:integer (floor (/ new-user-score 5.0)))
                (diff-urstoa:integer (- new-urstoa-earned present-urstoa-earned))
            )
            (if (= diff-urstoa 0)
                ;;do nothing
                true
                (let
                    (
                        (final-urstoa-earned:integer
                            (if (< urstoa-left diff-urstoa)
                                (+ present-urstoa-earned urstoa-left)
                                new-urstoa-earned
                            )


                        )
                        (final-urstoa-left:integer
                            (if (< urstoa-left diff-urstoa)
                                0
                                (- urstoa-left diff-urstoa)
                            )
                        )
                    )
                    (update STOAICO|T|User account
                        {"urstoa-earned"    : final-urstoa-earned}
                    )
                    (update STOAICO|T|General STOAICO|INFO
                        {"urstoa-left"      : final-urstoa-left}
                    )
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun A_InitialiseDistributionVault (account:string)
        @doc "Initialises the Distribuition Vault by creating and filling all necesary prerequisites"
        (with-capability (INIT-ICO-DISTRIBUTION)
            (let
                (
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (dptf-ids:list 
                        (ref-TS01-C1::DPTF|C_Issue account account
                            ["WrappedUrStoa" "VirtualIcoDollars"]
                            ["WURSTOA" "VUSDC"]
                            [3 2]
                            [true true]
                            [true true]
                            [true true]
                            [false false]
                            [false false]
                            [false false]
                        )
                    )
                    (wstoa-id:string (ref-DALOS::UR_WrappedStoaID))
                    (wurstoa-id:string (at 0 dptf-ids))
                    (vusd-id:string (at 1 dptf-ids))
                )
                ;;1]Issue wURSTOA as DPTF
                ;;2]Issue vUSD as mockup virtual Dollarz
                ;;3]Toggle mint and burn roles
                (ref-TS01-C1::DPTF|C_ToggleMintRole account vusd-id DEMIPAD|SC_NAME true)
                (ref-TS01-C1::DPTF|C_ToggleBurnRole account vusd-id DEMIPAD|SC_NAME true)
                (ref-TS01-C1::DPTF|C_ToggleMintRole account wstoa-id account true)
                (ref-TS01-C1::DPTF|C_ToggleMintRole account wurstoa-id DEMIPAD|SC_NAME true)
                ;;4]Mint 10 mil wSTOA (injection will follow after ICO concludes)    
                (ref-TS01-C1::DPTF|C_Mint account wstoa-id account 10000000.0 true)
                ;;5]Initialises the distribution Vault
                (XI_InitialiseDistributionVault [wstoa-id wurstoa-id vusd-id])
                ;;6]Output Message
                [wurstoa-id vusd-id]
            )
        )
    )
    (defun A_Inject (patron:string account:string wstoa-amount:decimal)
        @doc "Injects the ICO wSTOA amount into the Distribution-Vault (D-Vault); \
            \ the 10 mil from the ICO sale, from <account> \
            \ Can only be done by the ADMIN"
        (with-capability (STOAICO|INJECT account)
            (let
                (
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (wSTOA-ID:string (UR_Global8))
                    ;;
                    (vault-score:decimal (UR_Global1))
                    (zombie:decimal (UR_Global12))
                )
                (if (> vault-score 0.0)
                    ;;=== FLUSH — stakers present: distribute (new amount + any escrowed zombie), open next round.
                    (let
                        (
                            (eff:decimal (+ wstoa-amount zombie))
                        )
                        ;;#1C] Inject barrier — a new distribution-round may open ONLY when the previous one is
                        ;;     fully collected (unclaimed-count == 0). Stragglers are cleared by the admin flush.
                        (enforce
                            (= (UR_Global7) 0)
                            "STOAICO: previous distribution-round not fully collected — flush the stragglers (or wait for collections) before injecting again")
                        ;;0]Move wSTOA from <account> to the D-Vault
                        (ref-TS01-C1::DPTF|C_Transfer patron wSTOA-ID account DEMIPAD|SC_NAME wstoa-amount true)
                        ;;1]Count it in <wstoa-supply> (total held by the vault)
                        (XI_UpdateVaultSupply wstoa-amount true)
                        ;;2]Advance <current-rps> by the EFFECTIVE amount (new + escrowed zombie) / vault-score.
                        ;;  vault-score > 0 here, so the reward-per-share division can never divide by zero.
                        (XI_UpdateVaultRPS (+ (UR_Global6) (floor (/ eff vault-score) STOA_PREC)))
                        ;;3]#5M: the escrowed zombie is fully consumed by this flush
                        (if (> zombie 0.0) (XI_SetZombieRewards 0.0) true)
                        ;;4]Reset <unclaimed-count> (set it to <nzs-count>)
                        (XI_ResetUnclaimedCount)
                        ;;5]#1C: advance the vault to the next distribution-round (opens collection for this round)
                        (XI_IncrementDistributionRound)
                    )
                    ;;=== ESCROW — #5M no stakers (vault-score 0): park the amount as zombie for the NEXT non-zero
                    ;;    inject (eff = amount + zombie). Nothing is distributed (no rps/round/unclaimed change),
                    ;;    so the division is never reached with a zero denominator.
                    (do
                        ;;0]Move wSTOA from <account> to the D-Vault (held, not yet distributed)
                        (ref-TS01-C1::DPTF|C_Transfer patron wSTOA-ID account DEMIPAD|SC_NAME wstoa-amount true)
                        ;;1]Count it in <wstoa-supply> (held by the vault)
                        (XI_UpdateVaultSupply wstoa-amount true)
                        ;;2]Escrow: postpone distribution to the next injection when vault-score is non-zero
                        (XI_SetZombieRewards (+ zombie wstoa-amount))
                    )
                )
            )
        )
    )
    (defun A_Stake (patron:string account:string v-usd-amount:decimal)
        @doc "Adds a contribution in virtual $ to the Distribution Vault \
            \ Contributing with v-dollars allows for a piece of the 10 mil wSTOA \
            \ placed for distribution in this Vault.\
            \ Also earns urSTOA (up to 300k) \
            \ Can only be done by the Admin"
        (with-capability (STOAICO|ADD-CONTRIBUTION account v-usd-amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (v-usd-id:string (UR_Global10))
                    (user-score:decimal (UR_User1 account))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                ;;0]Mint the v-USD amount to the <DEMIPAD|SC_NAME>
                (ref-TS01-C1::DPTF|C_Mint patron v-usd-id DEMIPAD|SC_NAME v-usd-amount false)
                ;;0.1]If New Account
                (if (not (UR_IzAccount account))
                    (do
                        (insert STOAICO|T|User account
                            ;;#1C: new contributor starts at the CURRENT distribution-round, so a (mis-ordered)
                            ;;     post-inject stake is not eligible for the already-injected round.
                            (UDC_UserData 0.0 0 (UR_Global6) 0.0 (UR_Global11) account)
                        )
                        ;;Increment Users by one
                        (update STOAICO|T|General STOAICO|INFO
                            {"users" : (+ 1 (UR_Global3))}
                        )
                    )                
                    true
                )
                ;;1.1]Update Pending Rewards
                (XI_UpdatePendingRewards account)
                ;;1.2]If initial <user-score> was 0, increment <nzs-count>
                (if (= user-score 0.0)
                    (XI_UpdateNZS true)
                    true
                )
                ;;1.3]Update <last-rps> with D-Vault <current-rps>
                (XI_UpdateUserRPS account (UR_Global6))
                ;;1.4]#6M: Earn urSTOA ONLY during the ICO phase (distribution-round 0). After the ICO
                ;;    concludes (first inject → round >= 1) contributions no longer earn urSTOA; the unsold
                ;;    remainder of the 250k budget stays unminted (returns to the foundation).
                (if (= (UR_Global11) 0)
                    (XI_UpdateUrstoaEarned account v-usd-amount true)
                    true)
                ;;1.5]Update Vault Score and User Score
                (XI_UpdateVaultScore v-usd-amount true)
                (XI_UpdateUserScore account v-usd-amount true)
                (format "Succesfully contributed {} $ for Ouronet Account {}"
                    [v-usd-amount sa]
                )
            )
        )
    )
    (defun A_Unstake (patron:string account:string v-usd-amount:decimal)
        @doc "Removes a contribution of virtual $ from the Distribution Vault for an <account> \
            \ Can only be done by the ADMIN"
        (with-capability (STOAICO|REMOVE-CONTRIBUTION account v-usd-amount)
            (let
                (
                    (ref-I|OURONET:module{OuronetInfoV2} IGNIS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (v-usd-id:string (UR_Global10))
                    (user-score:decimal (UR_User1 account))
                    (remaining:decimal (- user-score v-usd-amount))
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount account))
                )
                ;;0]Burn the v-USD amount from the <DEMIPAD|SC_NAME> that is to be removed
                (ref-TS01-C1::DPTF|C_Burn patron v-usd-id DEMIPAD|SC_NAME v-usd-amount)
                ;;1.1]Update Pending Rewards
                (XI_UpdatePendingRewards account)
                ;;1.2]If remaining <user-score> becomes 0, decrement <nzs-count>
                (if (= remaining 0.0)
                    (XI_UpdateNZS false)
                    true
                )
                ;;1.3]Update <last-rps> with D-Vault <current-rps>
                (XI_UpdateUserRPS account (UR_Global6))
                ;;1.4]#6M: adjust urSTOA earning ONLY during the ICO phase (distribution-round 0); after the
                ;;    ICO concludes, contributions/withdrawals no longer touch urSTOA earning.
                (if (= (UR_Global11) 0)
                    (XI_UpdateUrstoaEarned account v-usd-amount false)
                    true)
                ;;1.5]Update Vault Score and User Score
                (XI_UpdateVaultScore v-usd-amount false)
                (XI_UpdateUserScore account v-usd-amount false)
                (format "Succesfully uncontributed {} $ for Ouronet Account {}"
                    [v-usd-amount sa]
                )
            )
        )
    )
    (defun Ap_FlushUncollectedSlice:string (patron:string accounts:[string])
        @doc "#1C Hydra parallel slice: the admin push-collects ONE slice of uncollected accounts, delivering \
            \ each its OWN wSTOA + urSTOA (identical to a self-collect — not to the admin, not burned). \
            \ Order-independent and retryable — an account already collected this round is skipped, so re-runs \
            \ are idempotent. Drives unclaimed-count toward 0 so the next A_Inject can open the following round."
        (with-capability (STOAICO|FLUSH)
            (let
                (
                    (cur-round:integer (UR_Global11))
                )
                (map
                    (lambda (account:string)
                        (if (< (UR_User5 account) cur-round)
                            (XI_CollectFor patron account)
                            (format "Account {} already collected — skipped" [account])
                        )
                    )
                    accounts
                )
                (format "Flush slice processed {} account(s)" [(length accounts)])
            )
        )
    )
    (defun AA_FlushUncollected:string (patron:string)
        @doc "#1C solo/heavy admin flush: push-collect ALL uncollected stragglers in one transaction (reaches \
            \ the URH_UncollectedAccounts heavy scan — hence AA_). For large contributor sets prefer the \
            \ parallel URH_UncollectedAccounts preflight + Ap_FlushUncollectedSlice legs. Delivers each \
            \ straggler its own rewards and clears unclaimed-count so the next inject can proceed."
        (with-capability (STOAICO|FLUSH)
            (let
                (
                    (accounts:[string] (URH_UncollectedAccounts))
                )
                (map (lambda (account:string) (XI_CollectFor patron account)) accounts)
                (format "Flushed {} uncollected account(s)" [(length accounts)])
            )
        )
    )
    (defun C_Collect (patron:string account:string)
        @doc "Self-collect from the distribution Vault — once per distribution-round, by the <account> owner. \
            \ A new A_Inject opens the next round and re-enables collection (the RPS delta since last collect)."
        (with-capability (STOAICO|REDEEM-CONTRIBUTION account)
            (XI_CollectFor patron account)
        )
    )

)

;; --- tables for 05_STOAICO.pact (4 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table STOAICO|T|User)
;; (create-table STOAICO|T|General)

